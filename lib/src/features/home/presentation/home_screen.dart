// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:sports_app/src/extensions/context_extensions.dart';
// import 'home_tab_others.dart';
// import 'home_tab_recommended.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
//   late final TabController _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         TabBar(
//           tabAlignment: TabAlignment.start,
//           isScrollable: true,
//           controller: _tabController,
//           indicator: BoxDecoration(),
//           labelStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//           unselectedLabelStyle: context.textTheme.bodyMedium,
//           tabs: [
//             Tab(text: 'home.tab.recommended'.tr()),
//             Tab(text: 'home.tab.basketball'.tr()),
//             Tab(text: 'home.tab.football'.tr()),
//           ],
//         ),
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: const [HomeTabRecommended(), HomeTabOthers(), HomeTabOthers()],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sports_app/src/features/home/presentation/home_tab_others.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabOthers();
  }
}
