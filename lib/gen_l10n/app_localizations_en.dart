// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Wood Cut Planner';

  @override
  String get settings => 'Settings';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get reload => 'Reload';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get close => 'Close';

  @override
  String get importProject => 'Import project';

  @override
  String get newProject => 'New Project';

  @override
  String get emptyProjectTitle => 'Create your first project';

  @override
  String get emptyProjectSubtitle =>
      'Tap the \"New Project\" button\nto start calculating your wood cuts.';

  @override
  String get selectProjectType => 'Select project type';

  @override
  String get cut1DTitle => '1D Cut (Lumber)';

  @override
  String get cut1DSubtitle => 'Optimize cuts along the length';

  @override
  String get cut2DTitle => '2D Cut (Sheet)';

  @override
  String get cut2DSubtitle => 'Optimize cuts on sheet area';

  @override
  String get duplicateProject => 'Duplicate project';

  @override
  String get deleteProject => 'Delete Project';

  @override
  String deleteProjectConfirm(String name) {
    return 'Delete \"$name\"?\nThis cannot be undone.';
  }

  @override
  String get importFailed => 'Failed to import file';

  @override
  String importSuccess(String name) {
    return 'Imported \"$name\"';
  }

  @override
  String duplicateCreated(String name) {
    return 'Created \"$name\"';
  }

  @override
  String get selectMaterial => 'Select material';

  @override
  String get allCategories => 'All';

  @override
  String get custom => 'Custom';

  @override
  String get customSettings => 'Custom settings';

  @override
  String get materialName => 'Material name';

  @override
  String get width => 'Width';

  @override
  String get height => 'Height';

  @override
  String get length => 'Length';

  @override
  String get startCutting => 'Start Cutting';

  @override
  String get pleaseSelectMaterial => 'Please select a material';

  @override
  String get pleaseEnterLength => 'Please enter length';

  @override
  String get enterPieces => 'Enter Pieces';

  @override
  String get sizesToCut => 'Sizes to cut';

  @override
  String get sizesToCut2D => 'Sizes to cut (2D)';

  @override
  String kerfWidthLabel(String width) {
    return 'Blade kerf: $width mm';
  }

  @override
  String get columnLength => 'Length(mm)';

  @override
  String get columnQuantity => 'Qty';

  @override
  String get columnWidth => 'Width(mm)';

  @override
  String get columnHeight => 'Height(mm)';

  @override
  String get columnLabel => 'Label';

  @override
  String get addSize => 'Add size';

  @override
  String get calculate => 'Calculate';

  @override
  String get inputError => 'Input Error';

  @override
  String errorLengthRequired(int row) {
    return 'Row $row: Please enter a length';
  }

  @override
  String errorQuantityRequired(int row) {
    return 'Row $row: Quantity must be at least 1';
  }

  @override
  String errorLengthExceeds(int row, String length, String stockLength) {
    return 'Row $row: Length (${length}mm) exceeds stock length (${stockLength}mm)';
  }

  @override
  String get errorNoPieces => 'Please enter at least one piece';

  @override
  String get resultTitle => 'Results';

  @override
  String get resultTitle2D => 'Results (2D)';

  @override
  String get checklistTooltip => 'Cut checklist';

  @override
  String get exportTooltip => 'Export';

  @override
  String get cutLayout => 'Cut Layout';

  @override
  String stockNumber(int n) {
    return 'Stock #$n';
  }

  @override
  String sheetNumber(int n) {
    return 'Sheet #$n';
  }

  @override
  String piecesWaste1D(int pieces, String waste) {
    return '$pieces pcs / Waste: ${waste}mm';
  }

  @override
  String piecesWaste2D(int pieces, String waste) {
    return '$pieces pcs / Waste: ${waste}mm²';
  }

  @override
  String get purchase => 'Buy';

  @override
  String get totalWaste => 'Total waste';

  @override
  String get utilizationRate => 'Utilization';

  @override
  String get costEstimate => 'Cost Estimate';

  @override
  String get unitPriceLabel => 'Price per piece:';

  @override
  String get totalCostLabel => 'Total cost';

  @override
  String costFormula(int count, String price, String total) {
    return '$count pcs × ¥$price = ¥$total';
  }

  @override
  String get saveProject => 'Save Project';

  @override
  String get projectUpdated => 'Project updated';

  @override
  String projectSaved(String name) {
    return 'Saved \"$name\"';
  }

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get projectNameDialogTitle => 'Project Name';

  @override
  String get projectNameHint => 'e.g. Bookshelf cuts';

  @override
  String defaultProjectName(String woodName) {
    return '$woodName cut plan';
  }

  @override
  String get checklistTitle => 'Cut Checklist';

  @override
  String get checklistComplete => 'All cuts done!';

  @override
  String get checklistReset => 'Reset';

  @override
  String checklistProgress(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get selectSheet => 'Select Sheet';

  @override
  String get customSheet => 'Custom sheet';

  @override
  String get customSheetSettings => 'Custom sheet settings';

  @override
  String get thickness => 'Thickness';

  @override
  String thicknessLabel(String thickness) {
    return 'Thickness ${thickness}mm';
  }

  @override
  String get enterPieces2D => 'Enter Pieces (2D)';

  @override
  String get kerfWidthSetting => 'Blade kerf width';

  @override
  String get kerfWidthDescription =>
      'Wood lost per cut. A typical saw blade is about 3mm.';

  @override
  String get unitSystem => 'Unit system';

  @override
  String get unitMm => 'Millimeters (mm)';

  @override
  String get unitCm => 'Centimeters (cm)';

  @override
  String get recommended => 'Recommended';

  @override
  String get language => 'Language';

  @override
  String get languageJa => '日本語';

  @override
  String get languageEn => 'English';

  @override
  String get languageSystem => 'System default';

  @override
  String get appInfo => 'App Info';

  @override
  String get appInfoName => 'App name';

  @override
  String get appInfoVersion => 'Version';

  @override
  String get appInfoDescription => 'Description';

  @override
  String get appInfoDescriptionValue =>
      'DIY wood cut calculator\nAutomates optimal cut layouts to minimize waste.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get urlOpenFailed => 'Could not open URL';

  @override
  String get premiumTitle => 'Wood Cut Planner Premium';

  @override
  String get premiumDescription => 'No ads · PDF export · 2D sheet support';

  @override
  String get premiumPriceAppeal =>
      'Unlimited use for the price of a piece of wood';

  @override
  String get premiumCta => 'Learn more →';

  @override
  String get premiumComingSoon =>
      'Premium purchase will be available in a future update';

  @override
  String get onboardingTitle1 => 'Smart Wood Cut\nOptimization';

  @override
  String get onboardingBody1 =>
      'Simply enter the sizes you need and the app automatically calculates the optimal cut layout to minimize waste.';

  @override
  String get onboardingTitle2 => '1D & 2D Support';

  @override
  String get onboardingBody2 =>
      'Supports both length cuts for lumber (1D) and area cuts for plywood sheets (2D). Ready for any DIY project.';

  @override
  String get onboardingTitle3 => 'Cut Checklist\nKeeps You on Track';

  @override
  String get onboardingBody3 =>
      'Generate a cut checklist from your results. Check off each piece as you cut to avoid mistakes.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingTitle4 => 'How to\nGet Started';

  @override
  String get onboardingBody4 =>
      'Tap \"New Project\", select your material, enter the sizes you need, and tap \"Calculate\". The optimal cut layout appears automatically.';

  @override
  String get onboardingTitle5 => 'Save & Export';

  @override
  String get onboardingBody5 =>
      'Save your results as a project to revisit anytime. Export as PDF or CSV, and use backup & restore to keep your data safe.';

  @override
  String get onboardingTitle6 => 'Handy Tools';

  @override
  String get onboardingBody6 =>
      'Manage leftover offcuts in your inventory and reuse them in future projects. The built-in unit converter handles mm, cm, and inches with ease.';

  @override
  String get commonLengths => 'Common Lengths';

  @override
  String selectionSummaryLength(int length) {
    return 'Length: $length mm';
  }

  @override
  String selectionSummaryWithPrice(int length, int price) {
    return 'Length: $length mm / Ref. price: ¥$price';
  }

  @override
  String get themeSetting => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get searchProjects => 'Search projects';

  @override
  String searchNoResults(String query) {
    return 'No projects matching \"$query\"';
  }

  @override
  String get multipleStockLengths =>
      'Select multiple lengths (mix in optimization)';

  @override
  String stockLengthSummary(int count) {
    return '$count lengths';
  }

  @override
  String offcutSaved(String length) {
    return 'Offcut saved (${length}mm)';
  }

  @override
  String get saveOffcut => 'Save offcut';

  @override
  String get savedOffcuts => 'Saved offcuts';

  @override
  String get useOffcut => 'Use offcut';

  @override
  String offcutLength(String length) {
    return '${length}mm offcut';
  }

  @override
  String get noOffcuts => 'No saved offcuts';

  @override
  String offcutAdded(String length) {
    return 'Added ${length}mm offcut';
  }

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get fromOffcut => 'From offcut';

  @override
  String get useAsTemplate => 'Use as template';

  @override
  String get shareAsImage => 'Share as image';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get dataManagementDescription =>
      'Backup and restore all project and offcut data.\nUse iCloud Drive to transfer between devices.';

  @override
  String get exportBackup => 'Backup';

  @override
  String get importBackup => 'Restore';

  @override
  String backupImportSuccess(int projects, int offcuts) {
    return 'Restored: $projects projects, $offcuts offcuts';
  }

  @override
  String get backupImportFailed => 'Failed to restore backup';

  @override
  String get backupNoData => 'No data to backup';

  @override
  String defaultSheetProjectName(String sheetName) {
    return '$sheetName cut plan';
  }

  @override
  String get unitPriceLabelSheet => 'Price per sheet:';

  @override
  String costFormulaSheet(int count, String price, String total) {
    return '$count sheets × ¥$price = ¥$total';
  }

  @override
  String sheetsCount(int count) {
    return '$count sheets';
  }

  @override
  String get customPresets => 'Custom Presets';

  @override
  String get addCustomPreset => 'Add custom preset';

  @override
  String get editCustomPreset => 'Edit Preset';

  @override
  String get deletePreset => 'Delete Preset';

  @override
  String deletePresetConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String presetSaved(String name) {
    return 'Preset \"$name\" saved';
  }

  @override
  String get presetNameHint => 'e.g. 2x4 SPF';

  @override
  String get price => 'Price';

  @override
  String get frequentSizes => 'Frequent Sizes';

  @override
  String get frequentLabels => 'Frequent Labels';

  @override
  String usedNTimes(int count) {
    return 'Used $count times';
  }

  @override
  String get projectNotes => 'Notes';

  @override
  String get projectNotesHint => 'Enter notes...';

  @override
  String get attachPhoto => 'Attach Photo';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get offcutInventory => 'Offcut Inventory';

  @override
  String get offcutInventoryEmpty => 'No offcuts in inventory';

  @override
  String get offcutInventorySubtitle => 'Save offcuts from project results';

  @override
  String get addOffcutManually => 'Add offcut manually';

  @override
  String get offcutWoodName => 'Wood name';

  @override
  String offcutCount(int count) {
    return 'Offcuts: $count';
  }

  @override
  String get compareLayouts => 'Compare Layouts';

  @override
  String get comparisonResults => 'Comparison Results';

  @override
  String get strategyFFD => 'Largest First (FFD)';

  @override
  String get strategyBFD => 'Best Fit (BFD)';

  @override
  String get strategyFF => 'First Fit (FF)';

  @override
  String get bestResult => 'Best';

  @override
  String get stocksUsed => 'Stocks used';

  @override
  String get wasteAmount => 'Waste';

  @override
  String get useThisLayout => 'Use this layout';

  @override
  String get costDashboard => 'Cost Analysis';

  @override
  String get totalSpent => 'Total Cost';

  @override
  String get averageUtilization => 'Avg. Utilization';

  @override
  String get totalProjects => 'Projects';

  @override
  String get costByProject => 'Cost by Project';

  @override
  String get utilizationTrend => 'Utilization Trend';

  @override
  String get wasteByMaterial => 'Waste by Material';

  @override
  String get noDataForChart => 'No data to display';

  @override
  String get unitConverter => 'Unit Converter';

  @override
  String get convertFrom => 'From';

  @override
  String get convertTo => 'To';

  @override
  String get conversionResult => 'Result';

  @override
  String get allUnits => 'All Units';

  @override
  String get batchExport => 'Batch Export';

  @override
  String get batchExportTitle => 'Batch Export';

  @override
  String get selectProjects => 'Select Projects';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get exportFormat => 'Export Format';

  @override
  String get exportAsPdf => 'PDF';

  @override
  String get exportAsCsv => 'CSV';

  @override
  String exportSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get exportStarted => 'Export started';

  @override
  String get noProjectsSelected => 'Please select projects';

  @override
  String get tools => 'Tools';

  @override
  String get grainDirection => 'Grain';

  @override
  String get grainNone => 'None';

  @override
  String get grainHorizontal => 'Horiz.';

  @override
  String get grainVertical => 'Vert.';

  @override
  String get csvImport => 'Import CSV';

  @override
  String get csvImportEmpty => 'No parts found in the file';

  @override
  String csvImportSuccess(int count) {
    return 'Imported $count parts';
  }

  @override
  String get csvImportFailed => 'Failed to read CSV file';

  @override
  String get fractionModeOn => 'Enable fraction input';

  @override
  String get fractionModeOff => 'Switch to numeric input';

  @override
  String get fractionHint => 'e.g. 1/2, 3 1/4';
}
