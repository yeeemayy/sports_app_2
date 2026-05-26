import 'package:flutter/material.dart';
import 'package:sports_app/src/core/theme/app_theme.dart';

const _kPad = 16.0;

/// Column-header row used by football standings.
/// [cols] length must match [colWidths] length; index 2 is the flex team column.
class StandingsTableHeader extends StatelessWidget {
  const StandingsTableHeader({
    super.key,
    required this.cols,
    required this.colWidths,
  });

  final List<String> cols;
  final List<double> colWidths;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < cols.length; i++)
            i == 2
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        cols[i],
                        style: AppTextStyles.mono(8).copyWith(
                          color: context.appColors.text3,
                          letterSpacing: 8 * 0.1,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    width: colWidths[i],
                    child: Text(
                      cols[i],
                      style: AppTextStyles.mono(8).copyWith(
                        color: context.appColors.text3,
                        letterSpacing: 8 * 0.1,
                      ),
                      textAlign: i < 2 ? TextAlign.left : TextAlign.right,
                    ),
                  ),
        ],
      ),
    );
  }
}

/// Conference / division section header used by basketball and generic standings.
class ConferenceHeader extends StatelessWidget {
  const ConferenceHeader({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: _kPad, vertical: 7),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        border: Border(
          bottom: BorderSide(color: context.appColors.line, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            name,
            style: AppTextStyles.mono(
              9,
            ).copyWith(color: context.appColors.live, letterSpacing: 9 * 0.2),
          ),
        ],
      ),
    );
  }
}
