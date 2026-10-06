import "package:aloca_ufsc_front/user_interface/allocation/manage_venue/venue_screen.dart";
import "package:flutter/material.dart";
import "user_interface/home/home_screen.dart";
import "user_interface/event/event_screen.dart";

import "theme.dart";

class RootShell extends StatefulWidget {
    const RootShell({super.key});
    static RootShellState of(BuildContext context) => context.findAncestorStateOfType<RootShellState>()!;
    @override
    State<StatefulWidget> createState() => RootShellState();
}

class RootShellState extends State<RootShell> {
    final _tab = ValueNotifier<int>(1);
    final _nestedNav = GlobalKey<NavigatorState>();

    void switchTab(int index) {
        _nestedNav.currentState!.popUntil((r) => r.isFirst);
        _tab.value = index;
    }
    
    Future<T?> pushInShell<T>(Widget screen) {
        return _nestedNav.currentState!.push<T>(
            MaterialPageRoute(builder: (_) => screen),
        );
    }

    @override
      void dispose() {
        _tab.dispose();
        super.dispose();
      }
   
    @override
    Widget build(BuildContext context) {
        return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                final nav = _nestedNav.currentState;
                if (nav != null && nav.canPop()) nav.pop();
            },
            child: Scaffold(
                backgroundColor: AppColors.background,
                extendBody: true,
                body: Navigator(
                    key: _nestedNav,
                    onGenerateRoute: (_) => MaterialPageRoute(
                        builder: (_) => ValueListenableBuilder<int>(
                            valueListenable: _tab,
                            builder: (_, index, __) => const [
                                EventScreen(),
                                HomeScreen(),
                                VenueScreen(),
                            ][index]
                        ),
                    ),
                ),
                bottomNavigationBar: ValueListenableBuilder<int>(
                    valueListenable: _tab,
                    builder: (_, index, __) => FloatingNavBar(selectedTab: index, handleTap:switchTab),
                ),
            ) 
        );
    }
}

class FloatingNavBar extends StatelessWidget {
    final int selectedTab;
    final ValueChanged<int> handleTap;

    const FloatingNavBar({super.key, required this.selectedTab, required this.handleTap});

    @override
    Widget build(BuildContext context) {
        final bottomInset = MediaQuery.of(context).viewPadding.bottom; 
        return Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, (bottomInset > 0) ? bottomInset : 0),
            child: Container(
                color: AppColors.background,
                child: SizedBox(
                    height: 70,
                    child: Row(
                        children: [
                           _item(0, Icons.event_note_outlined, Icons.event_note_rounded, 'Eventos', context),
                           _item(1, Icons.home_outlined, Icons.home_rounded, 'Home', context),
                           _item(2, Icons.meeting_room_outlined, Icons.meeting_room, 'Alocações', context),
                        ]
                    )
                )
            )
        );
    }

    Widget _item(int i, IconData icon, IconData activeIcon, String label, BuildContext context) {
        final selected = (selectedTab == i);
        final color = selected ? AppColors.secondaryBlue : AppColors.textSecondary;
        return Expanded(
            child: GestureDetector(
                onTap: Feedback.wrapForTap(() => handleTap(i), context),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: selected ? AppColors.mainBlue : AppColors.background,
                        borderRadius: BorderRadius.circular(100),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Icon(selected ? activeIcon : icon, size: 25, color: color),
                            const SizedBox(height: 3),
                            Text(
                                label,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                    color: color,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}
