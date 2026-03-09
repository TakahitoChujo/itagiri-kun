import '../models/wood_stock.dart';
import '../models/sheet_models.dart';

/// 日本のホームセンターで一般的に販売されている規格材のプリセット一覧
///
/// SPF材（スプルース・パイン・ファー）を中心に、
/// DIYでよく使われるサイズを網羅している。
/// 寸法はすべてミリメートル (mm) 単位。
/// 参考価格は 2024年時点のホームセンター平均価格（税込概算）。
final List<WoodStock> woodPresets = [
  // --- SPF材 ---
  WoodStock(
    name: '1x4',
    width: 19,
    height: 89,
    lengths: [910, 1820, 2440, 3650],
    category: 'SPF',
    prices: [198, 348, 498, 698],
  ),
  WoodStock(
    name: '2x4',
    width: 38,
    height: 89,
    lengths: [910, 1820, 2440, 3050, 3650],
    category: 'SPF',
    prices: [298, 498, 698, 898, 1098],
  ),
  WoodStock(
    name: '1x6',
    width: 19,
    height: 140,
    lengths: [910, 1820, 2440],
    category: 'SPF',
    prices: [298, 498, 698],
  ),
  WoodStock(
    name: '2x6',
    width: 38,
    height: 140,
    lengths: [1820, 2440, 3650],
    category: 'SPF',
    prices: [798, 1098, 1598],
  ),
  WoodStock(
    name: '1x8',
    width: 19,
    height: 184,
    lengths: [910, 1820, 2440],
    category: 'SPF',
    prices: [398, 698, 998],
  ),
  WoodStock(
    name: '2x8',
    width: 38,
    height: 184,
    lengths: [1820, 2440, 3650],
    category: 'SPF',
    prices: [1098, 1498, 2198],
  ),
  WoodStock(
    name: '1x10',
    width: 19,
    height: 235,
    lengths: [910, 1820],
    category: 'SPF',
    prices: [498, 898],
  ),
  WoodStock(
    name: '2x10',
    width: 38,
    height: 235,
    lengths: [1820, 2440],
    category: 'SPF',
    prices: [1498, 1998],
  ),

  // --- 杉 (Cedar) ---
  WoodStock(
    name: '杉 野縁',
    width: 30,
    height: 40,
    lengths: [1820, 2000, 3000],
    category: '杉',
    prices: [198, 228, 348],
  ),
  WoodStock(
    name: '杉 角材',
    width: 45,
    height: 45,
    lengths: [910, 1820, 2000],
    category: '杉',
    prices: [298, 498, 548],
  ),
  WoodStock(
    name: '杉板',
    width: 12,
    height: 180,
    lengths: [910, 1820],
    category: '杉',
    prices: [298, 548],
  ),

  // --- 桧 (Cypress) ---
  WoodStock(
    name: '桧 角材',
    width: 30,
    height: 30,
    lengths: [910, 1820],
    category: '桧',
    prices: [298, 548],
  ),
  WoodStock(
    name: '桧板',
    width: 12,
    height: 120,
    lengths: [910, 1820],
    category: '桧',
    prices: [398, 698],
  ),

  // --- 集成材 (Laminated) ---
  WoodStock(
    name: 'パイン集成材',
    width: 18,
    height: 200,
    lengths: [910, 1820],
    category: '集成材',
    prices: [998, 1798],
  ),
  WoodStock(
    name: 'パイン集成材(幅広)',
    width: 18,
    height: 300,
    lengths: [910, 1820],
    category: '集成材',
    prices: [1498, 2498],
  ),
  WoodStock(
    name: 'パイン集成材(厚板)',
    width: 25,
    height: 250,
    lengths: [910, 1820],
    category: '集成材',
    prices: [1598, 2798],
  ),
];

/// カテゴリ一覧を取得する
List<String> get woodCategories {
  final categories = <String>{};
  for (final wood in woodPresets) {
    if (wood.category != null) {
      categories.add(wood.category!);
    }
  }
  return categories.toList();
}

/// カテゴリでフィルタリングした木材リストを取得する
List<WoodStock> woodPresetsForCategory(String? category) {
  if (category == null) return woodPresets;
  return woodPresets.where((w) => w.category == category).toList();
}

// ---------------------------------------------------------------------------
// 合板（シート材）プリセット
// ---------------------------------------------------------------------------

/// ホームセンターで一般的に販売されている合板のプリセット一覧
final List<SheetStock> sheetPresets = [
  SheetStock(
    name: 'ラワン合板 (2.5mm)',
    width: 910,
    height: 1820,
    thickness: 2.5,
    price: 698,
  ),
  SheetStock(
    name: 'ラワン合板 (4mm)',
    width: 910,
    height: 1820,
    thickness: 4,
    price: 998,
  ),
  SheetStock(
    name: 'ラワン合板 (9mm)',
    width: 910,
    height: 1820,
    thickness: 9,
    price: 1698,
  ),
  SheetStock(
    name: 'ラワン合板 (12mm)',
    width: 910,
    height: 1820,
    thickness: 12,
    price: 1998,
  ),
  SheetStock(
    name: '針葉樹合板 (12mm)',
    width: 910,
    height: 1820,
    thickness: 12,
    price: 1298,
  ),
  SheetStock(
    name: 'シナ合板 (4mm)',
    width: 910,
    height: 1820,
    thickness: 4,
    price: 1498,
  ),
  SheetStock(
    name: 'シナ合板 (9mm)',
    width: 910,
    height: 1820,
    thickness: 9,
    price: 2498,
  ),
  SheetStock(
    name: 'MDF (5.5mm)',
    width: 910,
    height: 1820,
    thickness: 5.5,
    price: 898,
  ),
  SheetStock(
    name: 'MDF (9mm)',
    width: 910,
    height: 1820,
    thickness: 9,
    price: 1298,
  ),
  SheetStock(
    name: 'OSB (9mm)',
    width: 910,
    height: 1820,
    thickness: 9,
    price: 998,
  ),
  SheetStock(
    name: 'OSB (12mm)',
    width: 910,
    height: 1820,
    thickness: 12,
    price: 1498,
  ),
];
