import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_manager.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backgrounds/theater_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header con info utente
                    _buildUserHeader(context, userProvider, l10n),
                    const SizedBox(height: 20),
                    // Tab Bar
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color(0xFF8B0000),
                        ),
                        tabs: [
                          Tab(text: l10n.get('statistics')),
                          Tab(text: l10n.get('badges')),
                          Tab(text: l10n.get('titles')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildStatisticsTab(userProvider, l10n),
                          _buildBadgesTab(userProvider, l10n),
                          _buildTitlesTab(userProvider, l10n),
                        ],
                      ),
                    ),
                    // Back button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: GestureDetector(
                          onTap: () {
                            AudioManager().playNavigationBack();
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                            'assets/images/icons/backicon.png',
                            width: 55,
                            height: 55,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, UserProvider userProvider, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF8B0000), width: 2),
      ),
      child: Column(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF8B0000),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 10),
          // Username con edit
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userProvider.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                onPressed: () => _showEditUsernameDialog(context, userProvider, l10n),
              ),
            ],
          ),
          // Titolo corrente
          Text(
            l10n.get(userProvider.currentTitle?.internalName ?? 'novice'),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          // Level e XP
          Text(
            '${l10n.get('level')} ${userProvider.level}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // XP Progress Bar
          Container(
            width: 200,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: userProvider.xpProgressPercentage,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${userProvider.xpProgress} / ${userProvider.xpForNextLevel} XP',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(UserProvider userProvider, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            _buildStatRow(l10n.get('games_played'), userProvider.gamesPlayed.toString()),
            _buildStatRow(l10n.get('games_won'), userProvider.gamesWon.toString()),
            _buildStatRow(l10n.get('games_lost'), userProvider.gamesLost.toString()),
            _buildStatRow(l10n.get('win_rate'), '${userProvider.winRate.toStringAsFixed(1)}%'),
            const Divider(color: Colors.white30),
            _buildStatRow(l10n.get('correct_answers'), userProvider.correctAnswers.toString()),
            _buildStatRow(l10n.get('wrong_answers'), userProvider.wrongAnswers.toString()),
            _buildStatRow(l10n.get('accuracy'), '${userProvider.accuracy.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(UserProvider userProvider, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Badge counter
          Text(
            '${l10n.get('badges')}: ${userProvider.unlockedBadges.length} / ${userProvider.allBadges.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Badge grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: userProvider.allBadges.length,
              itemBuilder: (context, index) {
                final badge = userProvider.allBadges[index];
                final isUnlocked = userProvider.unlockedBadgeIds.contains(badge.badgeId);

                return GestureDetector(
                  onTap: () => _showBadgeDetails(context, badge, isUnlocked, l10n),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isUnlocked
                          ? Color(badge.rarityColor).withValues(alpha: 0.3)
                          : Colors.grey[800]?.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isUnlocked ? Color(badge.rarityColor) : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        badge.iconEmoji,
                        style: TextStyle(
                          fontSize: 30,
                          opacity: isUnlocked ? 1.0 : 0.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitlesTab(UserProvider userProvider, AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: userProvider.allTitles.length,
      itemBuilder: (context, index) {
        final title = userProvider.allTitles[index];
        final isSelected = title.titleId == userProvider.currentTitleId;
        final isUnlocked = userProvider.level >= _getLevelRequirement(title.internalName);

        return GestureDetector(
          onTap: isUnlocked ? () {
            AudioManager().playSeatClick();
            userProvider.changeTitle(title.titleId);
          } : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF8B0000).withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.amber : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.get(title.internalName),
                      style: TextStyle(
                        color: isUnlocked ? Colors.white : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title.unlockCondition,
                      style: TextStyle(
                        color: isUnlocked ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.amber),
                if (!isUnlocked)
                  const Icon(Icons.lock, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getLevelRequirement(String titleName) {
    switch (titleName) {
      case 'novice': return 1;
      case 'apprentice': return 10;
      case 'expert': return 25;
      case 'master': return 50;
      case 'legend': return 100;
      default: return 1;
    }
  }

  void _showEditUsernameDialog(BuildContext context, UserProvider userProvider, AppLocalizations l10n) {
    final controller = TextEditingController(text: userProvider.username);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          l10n.get('change_username'),
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          maxLength: 20,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.get('enter_new_username'),
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                userProvider.updateUsername(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.get('confirm')),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, dynamic badge, bool isUnlocked, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        title: Text(
          l10n.get(badge.internalName),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.iconEmoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.get('${badge.internalName}_desc'),
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Color(badge.rarityColor),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                l10n.get(badge.rarity),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 10),
              Text(
                l10n.get('locked'),
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.get('close')),
          ),
        ],
      ),
    );
  }
}