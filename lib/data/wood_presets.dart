import '../models/wood_stock.dart';

/// 日本のホームセンターで一般的に販売されている規格材のプリセット一覧
///
/// SPF材（スプルース・パイン・ファー）を中心に、
/// DIYでよく使われるサイズを網羅している。
/// 寸法はすべてミリメートル (mm) 単位。
final List<WoodStock> woodPresets = [
  // --- SPF材 ---
  WoodStock(
    name: '1x4',
    width: 19,
    height: 89,
    lengths: [910, 1820, 2440, 3650],
  ),
  WoodStock(
    name: '2x4',
    width: 38,
    height: 89,
    lengths: [910, 1820, 2440, 3050, 3650],
  ),
  WoodStock(
    name: '1x6',
    width: 19,
    height: 140,
    lengths: [910, 1820, 2440],
  ),
  WoodStock(
    name: '2x6',
    width: 38,
    height: 140,
    lengths: [1820, 2440, 3650],
  ),
  WoodStock(
    name: '1x8',
    width: 19,
    height: 184,
    lengths: [910, 1820, 2440],
  ),
  WoodStock(
    name: '2x8',
    width: 38,
    height: 184,
    lengths: [1820, 2440, 3650],
  ),
  WoodStock(
    name: '1x10',
    width: 19,
    height: 235,
    lengths: [910, 1820],
  ),
  WoodStock(
    name: '2x10',
    width: 38,
    height: 235,
    lengths: [1820, 2440],
  ),
];
