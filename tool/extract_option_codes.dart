import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String teslaApiDocsOptionCodesMarkdownUrl =
    "https://raw.githubusercontent.com/timdorr/tesla-api/master/docs/vehicle/optioncodes.md";

const JsonCodec _json = const JsonCodec();

Future main() async {
  var client = new HttpClient();
  var request =
      await client.getUrl(Uri.parse(teslaApiDocsOptionCodesMarkdownUrl));
  var response = await request.close();

  print(r"""
part of tesla;

class VehicleOptionCode {
  const VehicleOptionCode(this.code, this.description);

  final String code;
  final String description;

  @override
  String toString() => "VehicleOptionCode(${code}, ${description})";
""");

  var codes = <String>[];
  var seen = <String, String>{};

  await for (var line in response
      .cast<List<int>>()
      .transform(const Utf8Decoder())
      .transform(const LineSplitter())) {
    if (!line.startsWith("| ")) {
      continue;
    }

    if (line.startsWith("| Code") || line.startsWith("| :")) {
      continue;
    }

    var parts = line
        .split("| ")
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty)
        .toList();

    var code = parts[0];
    var description = parts[1];

    if (seen.containsKey(code)) {
      if (seen[code] == description) {
        continue;
      }
      code = "${code}_0";
    }
    print("  // ignore: constant_identifier_names");
    print(
        "  static const VehicleOptionCode ${code} = const VehicleOptionCode(${_json.encode(code)}, ${_json.encode(description)});");
    codes.add(code);
    seen[code] = description;
  }

  print("");
  print(
      "  static const List<VehicleOptionCode> values = const <VehicleOptionCode>[");

  while (codes.isNotEmpty) {
    var sub = codes.take(codes.length > 8 ? 8 : codes.length).join(", ");
    codes.removeRange(0, (codes.length > 8 ? 8 : codes.length));
    print("    ${sub}${codes.length > 0 ? ',' : ''}");
  }

  print("  ];");

  print("""

  static VehicleOptionCode lookup(String code) {
    return values.firstWhere((c) => c.code == code, orElse: () => null);
  }""");

  print("}");

  exit(0);
}
