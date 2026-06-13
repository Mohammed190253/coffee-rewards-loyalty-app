import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_user_repository.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/stamp_model.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final IUserRepository _userRepository;

  UserCubit(this._userRepository) : super(UserInitial());

  Future<void> fetchUserProfile() async {
    emit(UserLoading());
    try {
      final user = await _userRepository.getUserProfile();
      emit(UserLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  void deductWallet(double amount) {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = User(
        name: currentUser.name,
        currentStars: currentUser.currentStars,
        totalStarsForNextTier: currentUser.totalStarsForNextTier,
        tierName: currentUser.tierName,
        walletBalance: currentUser.walletBalance - amount,
        qrCodeData: currentUser.qrCodeData,
        earnedStamps: currentUser.earnedStamps,
      );
      emit(UserLoaded(updatedUser));
    }
  }

  StampModel? completeFocusSession(int minutesSpent, String branchName) {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      
      String? targetStampId;
      int starReward = 0;
      
      if (minutesSpent >= 90) {
        targetStampId = 'scholar_laureate';
        starReward = 600;
      } else if (minutesSpent >= 60) {
        targetStampId = 'celestial_navigator';
        starReward = 400;
      } else if (minutesSpent >= 45) {
        targetStampId = 'al_khwarizmi';
        starReward = 250;
      } else if (minutesSpent >= 25) {
        targetStampId = 'ibn_battuta';
        starReward = 150;
      }

      if (targetStampId == null) return null;

      StampModel? newlyUnlockedStamp;
      final updatedStamps = currentUser.earnedStamps.map((stamp) {
        if (stamp.id == targetStampId && !stamp.isUnlocked) {
          final now = DateTime.now();
          final dateStr = "${_getMonthName(now.month)} ${now.day}, ${now.year}";
          newlyUnlockedStamp = stamp.copyWith(
            isUnlocked: true,
            dateEarned: dateStr,
            branchName: branchName,
          );
          return newlyUnlockedStamp!;
        }
        return stamp;
      }).toList();

      if (newlyUnlockedStamp != null) {
        // Increment stars
        int newStars = currentUser.currentStars + starReward;
        String newTier = currentUser.tierName;
        int nextTierThreshold = currentUser.totalStarsForNextTier;
        
        // If stars exceed next tier, upgrade level!
        if (newStars >= nextTierThreshold) {
          newTier = "Voyager Level 5";
        }

        final updatedUser = User(
          name: currentUser.name,
          currentStars: newStars,
          totalStarsForNextTier: nextTierThreshold,
          tierName: newTier,
          walletBalance: currentUser.walletBalance,
          qrCodeData: currentUser.qrCodeData,
          earnedStamps: updatedStamps,
        );
        emit(UserLoaded(updatedUser));
        return newlyUnlockedStamp;
      }
    }
    return null;
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (month >= 1 && month <= 12) return months[month - 1];
    return "May";
  }
}
