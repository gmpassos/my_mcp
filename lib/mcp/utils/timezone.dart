// Copyright (c) 2026 UnyGPT
// This file is part of the UnySys project.
// All rights reserved.

import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

export 'package:timezone/timezone.dart' show TZDateTime;

class TimeZone {
  static bool _boot = false;

  static void boot() {
    if (_boot) return;
    _boot = true;

    tz_data.initializeTimeZones();
  }

  TimeZone._() {
    boot();
  }

  static final TimeZone _instance = TimeZone._();

  factory TimeZone() => _instance;

  Map<String, tz.Location> get locations => tz.timeZoneDatabase.locations;

  tz.Location getLocationGMT() => tz.getLocation('GMT');

  // USA:

  tz.Location getLocationUSLosAngeles() =>
      tz.getLocation('America/Los_Angeles');

  tz.Location getLocationUSChicago() => tz.getLocation('America/Chicago');

  tz.Location getLocationUSNewYork() => tz.getLocation('America/NewYork');

  tz.Location getLocationUSDenver() => tz.getLocation('America/Denver');

  tz.Location getLocationUSAnchorage() => tz.getLocation('America/Anchorage');

  tz.Location getLocationUSHonolulu() => tz.getLocation('America/Honolulu');

  List<tz.Location> getLocationUS() => [
        getLocationUSLosAngeles(),
        getLocationUSChicago(),
        getLocationUSNewYork(),
        getLocationUSDenver(),
        getLocationUSAnchorage(),
        getLocationUSHonolulu(),
      ];

  // Canada

  tz.Location getLocationCAToronto() => tz.getLocation('America/Toronto');

  tz.Location getLocationCAWinnipeg() => tz.getLocation('America/Winnipeg');

  tz.Location getLocationCAEdmonton() => tz.getLocation('America/Edmonton');

  tz.Location getLocationCAVancouver() => tz.getLocation('America/Vancouver');

  tz.Location getLocationCAHalifax() => tz.getLocation('America/Halifax');

  tz.Location getLocationCAStJohns() => tz.getLocation('America/St_Johns');

  List<tz.Location> getLocationCA() => [
        getLocationCAToronto(),
        getLocationCAWinnipeg(),
        getLocationCAEdmonton(),
        getLocationCAVancouver(),
        getLocationCAHalifax(),
        getLocationCAStJohns(),
      ];

  // Mexico:

  tz.Location getLocationMXMexicoCity() =>
      tz.getLocation('America/Mexico_City');

  tz.Location getLocationMXTijuana() => tz.getLocation('America/Tijuana');

  tz.Location getLocationMXMonterrey() => tz.getLocation('America/Monterrey');

  List<tz.Location> getLocationMX() => [
        getLocationMXMexicoCity(),
        getLocationMXTijuana(),
        getLocationMXMonterrey(),
      ];

  // Central America:

  tz.Location getLocationGTMGuatemala() => tz.getLocation('America/Guatemala');

  tz.Location getLocationBLZBelize() => tz.getLocation('America/Belize');

  tz.Location getLocationMXCancun() => tz.getLocation('America/Cancun');

  tz.Location getLocationJMKingson() => tz.getLocation('America/Kingston');

  tz.Location getLocationPANPanama() => tz.getLocation('America/Panama');

  // Brazil:

  tz.Location getLocationBRSaoPaulo() => tz.getLocation('America/Sao_Paulo');

  tz.Location getLocationBRNoronha() => tz.getLocation('America/Noronha');

  tz.Location getLocationBRManaus() => tz.getLocation('America/Manaus');

  tz.Location getLocationBRRioBranco() => tz.getLocation('America/Rio_Branco');

  List<tz.Location> getLocationBR() => [
        getLocationBRSaoPaulo(),
        getLocationBRNoronha(),
        getLocationBRManaus(),
        getLocationBRRioBranco(),
      ];

  // South America:

  tz.Location getLocationAR() =>
      tz.getLocation('America/Argentina/Buenos_Aires');

  tz.Location getLocationCL() => tz.getLocation('America/Santiago');

  tz.Location getLocationCO() => tz.getLocation('America/Bogota');

  tz.Location getLocationPE() => tz.getLocation('America/Lima');

  tz.Location getLocationVE() => tz.getLocation('America/Caracas');

  tz.Location getLocationUY() => tz.getLocation('America/Montevideo');

  tz.Location getLocationPY() => tz.getLocation('America/Asuncion');

  tz.Location getLocationEC() => tz.getLocation('America/Guayaquil');

  tz.Location getLocationBO() => tz.getLocation('America/La_Paz');

  tz.Location getLocationGY() => tz.getLocation('America/Guyana');

  tz.Location getLocationSR() => tz.getLocation('America/Paramaribo');

  tz.Location getLocationFG() => tz.getLocation('America/Cayenne');

  // Europe:

  tz.Location getLocationLU() => tz.getLocation('Europe/Luxembourg');

  tz.Location getLocationFR() => tz.getLocation('Europe/Paris');

  tz.Location getLocationES() => tz.getLocation('Europe/Madrid');

  tz.Location getLocationUK() => tz.getLocation('Europe/London');

  tz.Location getLocationDE() => tz.getLocation('Europe/Berlin');

  tz.Location getLocationIT() => tz.getLocation('Europe/Rome');

  tz.Location getLocationVA() => tz.getLocation('Europe/Vatican');

  tz.Location getLocationMC() => tz.getLocation('Europe/Monaco');

  tz.Location getLocationBE() => tz.getLocation('Europe/Brussels');

  tz.Location getLocationCH() => tz.getLocation('Europe/Zurich');

  tz.Location getLocationAT() => tz.getLocation('Europe/Vienna');

  tz.Location getLocationPT() => tz.getLocation('Europe/Lisbon');

  tz.Location getLocationIE() => tz.getLocation('Europe/Dublin');

  tz.Location getLocationNL() => tz.getLocation('Europe/Amsterdam');

  tz.Location getLocationDK() => tz.getLocation('Europe/Copenhagen');

  tz.Location getLocationSE() => tz.getLocation('Europe/Stockholm');

  tz.Location getLocationNO() => tz.getLocation('Europe/Oslo');

  tz.Location getLocationFI() => tz.getLocation('Europe/Helsinki');

  tz.Location getLocationGR() => tz.getLocation('Europe/Athens');

  tz.Location getLocationSK() => tz.getLocation('Europe/Bratislava');

  tz.Location getLocationCZ() => tz.getLocation('Europe/Prague');

  tz.Location getLocationHU() => tz.getLocation('Europe/Budapest');

  tz.Location getLocationIS() => tz.getLocation('Atlantic/Reykjavik');

  // Japan:

  tz.Location getLocationJPTokyo() => tz.getLocation('Asia/Tokyo');

  // South Korea:

  tz.Location getLocationKRSoul() => tz.getLocation('Asia/Seoul');

  // Australia:

  tz.Location getLocationAUSydney() => tz.getLocation('Australia/Sydney');

  tz.Location getLocationAUMelbourne() => tz.getLocation('Australia/Melbourne');

  tz.Location getLocationAUBrisbane() => tz.getLocation('Australia/Brisbane');

  tz.Location getLocationAULongreach() => tz.getLocation('Australia/Longreach');

  tz.Location getLocationAUCairns() => tz.getLocation('Australia/Cairns');

  List<tz.Location> getLocationAU() => [
        getLocationAUSydney(),
        getLocationAUMelbourne(),
        getLocationAUBrisbane(),
        getLocationAULongreach(),
        getLocationAUCairns(),
      ];

  // New Zealand:

  tz.Location getLocationNZAuckland() => tz.getLocation('Pacific/Auckland');

  tz.Location getLocationNZWellington() => tz.getLocation('Pacific/Wellington');

  List<tz.Location> getLocationNZ() => [
        getLocationNZAuckland(),
        getLocationNZWellington(),
      ];

  // China:

  tz.Location getLocationCNShanghai() => tz.getLocation('Asia/Shanghai');

  tz.Location getLocationCNBeijing() =>
      tz.getLocation('Asia/Shanghai'); // Same timezone

  tz.Location getLocationCNGuangzhou() =>
      tz.getLocation('Asia/Shanghai'); // Same timezone

  List<tz.Location> getLocationCN() => [
        getLocationCNShanghai(),
        getLocationCNBeijing(),
        getLocationCNGuangzhou(),
      ];

  //

  List<tz.Location>? getLocationsByCountryCode(String countryCode) {
    countryCode = countryCode.trim().toUpperCase();

    if (countryCode == 'GMT' || countryCode == 'UTC') {
      return [getLocationGMT()];
    }

    switch (countryCode) {
      case 'US':
        return getLocationUS();
      case 'CA':
        return getLocationCA();
      case 'MX':
        return getLocationMX();
      case 'NZ':
        return getLocationNZ();
      case 'AU':
        return getLocationAU();
      case 'CN':
        return getLocationCN();

      case 'GTM':
        return [getLocationGTMGuatemala()];
      case 'BLZ':
        return [getLocationBLZBelize()];
      case 'BR':
        return getLocationBR();
      case 'AR':
        return [getLocationAR()];
      case 'CL':
        return [getLocationCL()];
      case 'CO':
        return [getLocationCO()];
      case 'PE':
        return [getLocationPE()];
      case 'VE':
        return [getLocationVE()];
      case 'UY':
        return [getLocationUY()];
      case 'PY':
        return [getLocationPY()];
      case 'EC':
        return [getLocationEC()];
      case 'BO':
        return [getLocationBO()];
      case 'GY':
        return [getLocationGY()];
      case 'SR':
        return [getLocationSR()];
      case 'FG':
        return [getLocationFG()];

      case 'PT':
        return [getLocationPT()];
      case 'SE':
        return [getLocationSE()]; // Sweden
      case 'NO':
        return [getLocationNO()]; // Norway
      case 'FI':
        return [getLocationFI()]; // Finland
      case 'DK':
        return [getLocationDK()]; // Denmark
      case 'LU':
        return [getLocationLU()]; // Luxembourg
      case 'FR':
        return [getLocationFR()]; // France
      case 'ES':
        return [getLocationES()]; // Spain
      case 'UK':
        return [getLocationUK()]; // United Kingdom
      case 'DE':
        return [getLocationDE()]; // Germany
      case 'IT':
        return [getLocationIT()]; // Italy
      case 'VA':
        return [getLocationVA()]; // Vatican
      case 'MC':
        return [getLocationMC()]; // Monaco
      case 'BE':
        return [getLocationBE()]; // Belgium
      case 'CH':
        return [getLocationCH()]; // Switzerland
      case 'AT':
        return [getLocationAT()]; // Austria
      case 'IE':
        return [getLocationIE()]; // Ireland
      case 'NL':
        return [getLocationNL()]; // Netherlands
      case 'SK':
        return [getLocationSK()]; // Slovakia
      case 'CZ':
        return [getLocationCZ()]; // Czech Republic
      case 'HU':
        return [getLocationHU()]; // Hungary
      case 'GR':
        return [getLocationGR()]; // Greece

      case 'IS':
        return [getLocationIS()]; // Iceland

      case 'JP':
        return [getLocationJPTokyo()];
      case 'KR':
        return [getLocationKRSoul()];

      default:
        return null;
    }
  }

  tz.Location? getLocation(String countryCode, [String? stateCode]) {
    countryCode = countryCode.trim().toUpperCase();

    if (countryCode == 'GMT' || countryCode == 'UTC') {
      return getLocationGMT();
    }

    String validateStateCode(String? state, String country) {
      return state ??
          (throw StateError(
            "Need $country `stateCode` to define TimeZone Location!",
          ));
    }

    switch (countryCode) {
      case 'US':
        return getLocationUSByState(validateStateCode(stateCode, 'US'));
      case 'BR':
        return getLocationBRByState(validateStateCode(stateCode, 'BR'));
      case 'AU':
        return getLocationAUByState(validateStateCode(stateCode, 'AU'));
      case 'CA':
        return getLocationCAByState(validateStateCode(stateCode, 'CA'));
      case 'MX':
        return getLocationMXByState(validateStateCode(stateCode, 'MX'));
      case 'NZ':
        return getLocationNZByState(validateStateCode(stateCode, 'NZ'));
      case 'CN':
        return getLocationCNByCity(validateStateCode(stateCode, 'CN'));
      default:
        return getLocationsByCountryCode(countryCode)?.firstOrNull;
    }
  }

  tz.Location? getMainLocation(String countryCode, [String? stateCode]) {
    if (stateCode != null) {
      return getLocation(countryCode, stateCode);
    }

    return getLocationsByCountryCode(countryCode)?.firstOrNull;
  }

  tz.Location? getLocationUSByState(String stateCode) {
    stateCode = stateCode.trim().toUpperCase();

    switch (stateCode) {
      case 'AK':
        return getLocationUSAnchorage(); // America/Anchorage

      case 'HI':
        return getLocationUSHonolulu(); // America/Honolulu

      case 'NV':
      case 'CA':
      case 'AZ':
      case 'OR':
      case 'WA':
        return getLocationUSLosAngeles(); // America/Los_Angeles

      case 'CO':
      case 'MT':
      case 'NM':
      case 'WY':
      case 'ID':
      case 'UT':
        return getLocationUSDenver(); // America/Denver

      case 'AL':
      case 'AR':
      case 'FL':
      case 'GA':
      case 'IL':
      case 'IN':
      case 'IA':
      case 'KS':
      case 'KY':
      case 'LA':
      case 'MI':
      case 'MN':
      case 'MS':
      case 'MO':
      case 'NE':
      case 'ND':
      case 'OH':
      case 'OK':
      case 'SC':
      case 'SD':
      case 'TN':
      case 'TX':
      case 'WI':
        return getLocationUSChicago(); // America/Chicago

      case 'CT':
      case 'DE':
      case 'MA':
      case 'MD':
      case 'ME':
      case 'NH':
      case 'NJ':
      case 'NY':
      case 'NC':
      case 'PA':
      case 'RI':
      case 'VA':
      case 'WV':
      case 'PR':
      case 'VT':
      case 'DC':
        return getLocationUSNewYork(); // America/New_York

      default:
        throw StateError("Unknown US state: $stateCode");
    }
  }

  tz.Location? getLocationCAByState(String provinceCode) {
    provinceCode = provinceCode.trim().toUpperCase();

    switch (provinceCode) {
      case 'ON':
      case 'QC':
        return getLocationCAToronto(); // America/Toronto (most regions)

      case 'BC':
        return getLocationCAVancouver(); // America/Vancouver

      case 'AB':
        return getLocationCAEdmonton(); // America/Edmonton

      case 'MB':
      case 'SK':
        return getLocationCAWinnipeg(); // America/Winnipeg (most regions)

      case 'NS':
      case 'NB':
      case 'PE':
      case 'NL':
        return getLocationCAStJohns(); // America/St_Johns

      default:
        throw StateError("Unknown CA province code: $provinceCode");
    }
  }

  tz.Location? getLocationMXByState(String stateCode) {
    stateCode = stateCode.trim().toUpperCase();

    switch (stateCode) {
      case 'NL':
        return getLocationMXMonterrey(); // America/Monterrey

      case 'BCN':
        return getLocationMXTijuana(); // America/Tijuana

      case 'JAL':
      case 'CDMX':
      case 'DF':
      case 'MEX':
      case 'YUC':
      case 'VER':
      case 'PUE':
        return getLocationMXMexicoCity(); // America/Mexico_City

      default:
        throw StateError("Unknown MX state code: $stateCode");
    }
  }

  tz.Location? getLocationBRByState(String stateCode) {
    stateCode = stateCode.trim().toUpperCase();

    switch (stateCode) {
      case 'AC':
        return getLocationBRRioBranco(); // America/Rio_Branco

      case 'PE':
        return getLocationBRNoronha(); // America/Noronha

      case 'AM':
      case 'RR':
      case 'RO':
      case 'MT':
      case 'AP':
      case 'MS':
        return getLocationBRManaus(); // America/Manaus

      case 'AL':
      case 'CE':
      case 'MA':
      case 'PA':
      case 'PB':
      case 'PI':
      case 'RN':
      case 'BA':
      case 'DF':
      case 'GO':
      case 'TO':
      case 'SE':
      case 'ES':
      case 'MG':
      case 'RJ':
      case 'SP':
      case 'PR':
      case 'SC':
      case 'RS':
        return getLocationBRSaoPaulo(); // America/Sao_Paulo

      default:
        throw StateError("Unknown BR state: $stateCode");
    }
  }

  tz.Location? getLocationAUByState(String stateCode) {
    stateCode = stateCode.trim().toUpperCase();

    switch (stateCode) {
      case 'VIC':
        return getLocationAUMelbourne(); // Australia/Melbourne

      case 'QLD':
        return getLocationAUBrisbane(); // Australia/Brisbane

      case 'WA':
      case 'SA':
        return getLocationAULongreach(); // Australia/Longreach

      case 'NSW':
      case 'TAS':
      case 'NT':
      case 'ACT':
        return getLocationAUSydney(); // Australia/Sydney

      default:
        throw StateError("Unknown AU state code: $stateCode");
    }
  }

  tz.Location? getLocationNZByState(String regionCode) {
    regionCode = regionCode.trim().toUpperCase();

    switch (regionCode) {
      case 'WGN':
        return getLocationNZWellington(); // Pacific/Wellington

      case 'AUK':
      case 'CHC':
      case 'DUD':
      case 'GIS':
      case 'TAS':
        return getLocationNZAuckland(); // Pacific/Auckland

      default:
        throw StateError("Unknown NZ region code: $regionCode");
    }
  }

  tz.Location? getLocationCNByCity(String cityCode) {
    cityCode = cityCode.trim().toUpperCase();

    switch (cityCode) {
      case 'SH':
      case 'SHANGHAI':
        return getLocationCNShanghai(); // Asia/Shanghai

      case 'GZ':
      case 'GUANGZHOU':
      case 'SZ':
      case 'SHENZHEN':
      case 'HK':
      case 'HONGKONG':
        return getLocationCNGuangzhou(); // Asia/Shanghai (same timezone)

      case 'BJ':
      case 'BEIJING':
      case 'TJ':
      case 'TIANJIN':
        return getLocationCNBeijing(); // Asia/Shanghai (same timezone)

      default:
        throw StateError("Unknown CN city code: $cityCode");
    }
  }
}

extension TzLocationExtension on tz.Location {
  tz.TZDateTime now() => tz.TZDateTime.now(this);
}

extension TZDateTimeExtension on tz.TZDateTime {
  String toIso8601StringNoNanoseconds() {
    var offsetMs = timeZone.offset.inMilliseconds;

    var y = _fourDigits(year);
    var m = _twoDigits(month);
    var d = _twoDigits(day);
    var sep = "T";
    var h = _twoDigits(hour);
    var min = _twoDigits(minute);
    var sec = _twoDigits(second);
    var ms = _threeDigits(millisecond);

    if (isUtc) {
      return "$y-$m-$d$sep$h:$min:$sec.${ms}Z";
    } else {
      var offSign = offsetMs >= 0 ? '+' : '-';
      var totalSeconds = offsetMs.abs() ~/ 1000;
      var offH = _twoDigits(totalSeconds ~/ 3600);
      var offM = _twoDigits((totalSeconds % 3600) ~/ 60);

      return "$y-$m-$d$sep$h:$min:$sec.$ms$offSign$offH:$offM";
    }
  }

  static String _fourDigits(int n) {
    var absN = n.abs();
    var sign = n < 0 ? "-" : "";
    if (absN >= 1000) return "$n";
    if (absN >= 100) return "${sign}0$absN";
    if (absN >= 10) return "${sign}00$absN";
    return "${sign}000$absN";
  }

  static String _threeDigits(int n) {
    if (n >= 100) return "$n";
    if (n >= 10) return "0$n";
    return "00$n";
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  DateTime toDateTime({bool isUtc = true}) =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch, isUtc: isUtc);

  tz.TZDateTime addMonths(int monthsToAdd) {
    var tzDate = this;

    var newMonth = tzDate.month + monthsToAdd;
    var newYear = tzDate.year + (newMonth - 1) ~/ 12;

    newMonth = (newMonth - 1) % 12 + 1;

    var day = tzDate.day;
    var lastDayOfNewMonth = tz.TZDateTime(
      location,
      newYear,
      newMonth + 1,
      0,
    ).day;

    if (day > lastDayOfNewMonth) {
      day = lastDayOfNewMonth;
    }

    var tzDate2 = tz.TZDateTime(location, newYear, newMonth, day);
    return tzDate2;
  }

  tz.TZDateTime addDaysInsideMonth(int daysToAdd) {
    var date = this;
    var date2 = date.add(Duration(days: daysToAdd));
    if (date2.month != date.month) {
      date2 = tz.TZDateTime(
        location,
        date.year,
        date.month + 1,
        1,
        23,
        59,
        59,
      ).subtract(Duration(days: 1));
    }
    return date2;
  }

  (tz.TZDateTime, tz.TZDateTime) get monthPeriod {
    var tzDate = this;

    var year = tzDate.year;
    var month = tzDate.month;

    var periodStart = tz.TZDateTime(location, year, month, 1);
    var periodEnd = tz.TZDateTime(
      location,
      year,
      month + 1,
      1,
      23,
      59,
      59,
    ).subtract(Duration(days: 1));

    return (periodStart, periodEnd);
  }
}

extension DateTimeToTzExtension on DateTime {
  tz.TZDateTime toTZDateTime(tz.Location location) =>
      tz.TZDateTime.from(this, location);

  DateTime addMonths(
    tz.Location location,
    int monthsToAdd, {
    bool isUtc = true,
  }) {
    var tzDate = toTZDateTime(location);
    return tzDate.addMonths(monthsToAdd).toDateTime(isUtc: isUtc);
  }

  DateTime addDaysInsideMonth(
    tz.Location location,
    int daysToAdd, {
    bool isUtc = true,
  }) {
    var tzDate = toTZDateTime(location);
    return tzDate.addDaysInsideMonth(daysToAdd).toDateTime(isUtc: isUtc);
  }

  (DateTime, DateTime) monthPeriod(tz.Location location, {bool isUtc = true}) {
    var tzDate = toTZDateTime(location);
    var period = tzDate.monthPeriod;
    return (
      period.$1.toDateTime(isUtc: isUtc),
      period.$2.toDateTime(isUtc: isUtc),
    );
  }
}
