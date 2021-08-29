import 'package:better_player/better_player.dart';
import 'package:flutter_test/flutter_test.dart';
import 'better_player_mock_controller.dart';
import 'better_player_test_utils.dart';
import 'mock_method_channel.dart';
import 'mock_video_player_controller.dart';

MockMethodChannel? mockMethodChannel;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    "BetterPlayerController tests",
    () {
      setUp(() {
        mockMethodChannel = MockMethodChannel();
      });
      test("Create controller without data source", () {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerMockController(const BetterPlayerConfiguration());
        expect(betterPlayerMockController.betterPlayerDataSource, null);
        expect(betterPlayerMockController.videoPlayerController, null);
      });

      test("Setup data source in controller", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerMockController(const BetterPlayerConfiguration());
        await betterPlayerMockController.setupDataSource(
            BetterPlayerDataSource.network(
                BetterPlayerTestUtils.forBiggerBlazesUrl));
        expect(betterPlayerMockController.betterPlayerDataSource != null, true);
        expect(betterPlayerMockController.videoPlayerController != null, true);
      });

      test(
        "play should change isPlaying flag",
        () async {
          final BetterPlayerController betterPlayerController =
              BetterPlayerTestUtils.setupBetterPlayerMockController();
          final videoPlayerController =
              BetterPlayerTestUtils.setupMockVideoPlayerControler();
          betterPlayerController.videoPlayerController = videoPlayerController;
          await Future.delayed(const Duration(seconds: 1), () {});
          betterPlayerController.play();
          expect(betterPlayerController.isPlaying(), true);
        },
      );

      test(
        "pause should change isPlaying flag",
        () async {
          final BetterPlayerController betterPlayerController =
              BetterPlayerTestUtils.setupBetterPlayerMockController();
          final videoPlayerController =
              BetterPlayerTestUtils.setupMockVideoPlayerControler();
          betterPlayerController.videoPlayerController = videoPlayerController;
          await Future.delayed(const Duration(seconds: 1), () {});
          betterPlayerController.play();
          expect(betterPlayerController.isPlaying(), true);
          betterPlayerController.pause();
          expect(betterPlayerController.isPlaying(), false);
        },
      );

      test("full screen and auto play should work", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerMockController(
          const BetterPlayerConfiguration(
              fullScreenByDefault: true, autoPlay: true),
        );
        betterPlayerMockController.videoPlayerController =
            MockVideoPlayerController();
        await betterPlayerMockController.setupDataSource(
          BetterPlayerDataSource.network(
              BetterPlayerTestUtils.forBiggerBlazesUrl),
        );
        await Future.delayed(const Duration(seconds: 1), () {});
        expect(betterPlayerMockController.isFullScreen, true);
        expect(betterPlayerMockController.isPlaying(), true);
      });

      test("exitFullScreen should exit full screen", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController(
          controller: MockVideoPlayerController(),
        );
        expect(betterPlayerMockController.isFullScreen, false);
        betterPlayerMockController.exitFullScreen();
        expect(betterPlayerMockController.isFullScreen, false);
      });

      test("enterFullScreen should enter full screen", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        await betterPlayerMockController.setupDataSource(
          BetterPlayerDataSource.network(
              BetterPlayerTestUtils.forBiggerBlazesUrl),
        );
        expect(betterPlayerMockController.isFullScreen, false);
        betterPlayerMockController.enterFullScreen();
        expect(betterPlayerMockController.isFullScreen, true);
      });

      test("toggleFullScreen should change full screen state", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        await betterPlayerMockController.setupDataSource(
          BetterPlayerDataSource.network(
              BetterPlayerTestUtils.forBiggerBlazesUrl),
        );

        expect(betterPlayerMockController.isFullScreen, false);
        betterPlayerMockController.toggleFullScreen();
        expect(betterPlayerMockController.isFullScreen, true);
        betterPlayerMockController.toggleFullScreen();
        expect(betterPlayerMockController.isFullScreen, false);
      });

      test("setLooping changes looping state", () async {
        final mockVideoPlayerController = MockVideoPlayerController();
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        mockVideoPlayerController
            .setNetworkDataSource(BetterPlayerTestUtils.bugBuckBunnyVideoUrl);

        betterPlayerMockController.videoPlayerController =
            mockVideoPlayerController;
        expect(mockVideoPlayerController.isLoopingState, false);
        betterPlayerMockController.setLooping(true);
        expect(mockVideoPlayerController.isLoopingState, true);
        betterPlayerMockController.setLooping(false);
        expect(mockVideoPlayerController.isLoopingState, false);
      });

      test("setControlsVisibility updates controlVisiblityStream", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        var showCalls = 0;
        var hideCalls = 0;
        betterPlayerMockController.controlsVisibilityStream.listen((event) {
          if (event) {
            showCalls += 1;
          } else {
            hideCalls += 1;
          }
        });
        betterPlayerMockController.setControlsVisibility(false);
        betterPlayerMockController.setControlsVisibility(false);
        betterPlayerMockController.setControlsVisibility(true);
        betterPlayerMockController.setControlsVisibility(true);
        betterPlayerMockController.setControlsVisibility(false);
        await Future.delayed(const Duration(milliseconds: 100), () {});
        expect(hideCalls, 3);
        expect(showCalls, 2);
      });

      test("setControlsEnabled updates values correctly", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        var hideCalls = 0;
        betterPlayerMockController.controlsVisibilityStream.listen((event) {
          hideCalls += 1;
        });
        betterPlayerMockController.setControlsEnabled(false);
        betterPlayerMockController.setControlsEnabled(false);
        await Future.delayed(const Duration(milliseconds: 100), () {});
        expect(hideCalls, 2);
        expect(betterPlayerMockController.controlsEnabled, false);
        betterPlayerMockController.setControlsEnabled(true);
        expect(betterPlayerMockController.controlsEnabled, true);
      });

      test("toggleControlsVisibility sends correct events", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        var controlsVisibleEventCount = 0;
        var controlsHiddenEventCount = 0;
        betterPlayerMockController.addEventsListener((event) {
          if (event.betterPlayerEventType ==
              BetterPlayerEventType.controlsVisible) {
            controlsVisibleEventCount += 1;
          }
          if (event.betterPlayerEventType ==
              BetterPlayerEventType.controlsHidden) {
            controlsHiddenEventCount += 1;
          }
        });
        betterPlayerMockController.toggleControlsVisibility(false);
        betterPlayerMockController.toggleControlsVisibility(true);
        betterPlayerMockController.toggleControlsVisibility(true);
        await Future.delayed(const Duration(milliseconds: 100), () {});
        expect(controlsVisibleEventCount, 2);
        expect(controlsHiddenEventCount, 1);
      });

      test("postEvent sends events to listeners", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();

        int firstEventCounter = 0;
        int secondEventCounter = 0;

        betterPlayerMockController.addEventsListener((event) {
          firstEventCounter++;
        });
        betterPlayerMockController.addEventsListener((event) {
          secondEventCounter++;
        });
        betterPlayerMockController
            .postEvent(BetterPlayerEvent(BetterPlayerEventType.play));
        betterPlayerMockController
            .postEvent(BetterPlayerEvent(BetterPlayerEventType.progress));

        betterPlayerMockController
            .postEvent(BetterPlayerEvent(BetterPlayerEventType.pause));
        await Future.delayed(const Duration(milliseconds: 100), () {});
        expect(firstEventCounter, 3);
        expect(secondEventCounter, 3);
      });

      test("addEventsListener update list of event listener", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        betterPlayerMockController.addEventsListener((event) {});
        betterPlayerMockController.addEventsListener((event) {});
        //There's also additional internal listener.
        expect(betterPlayerMockController.eventListeners.length, 2);
      });

      void dummyEventListener(BetterPlayerEvent event) {}

      test("removeEventsListener update list of event listener", () async {
        final BetterPlayerMockController betterPlayerMockController =
            BetterPlayerTestUtils.setupBetterPlayerMockController();
        betterPlayerMockController.addEventsListener(dummyEventListener);
        betterPlayerMockController.addEventsListener((event) {});
        expect(betterPlayerMockController.eventListeners.length, 2);
        betterPlayerMockController.removeEventsListener(dummyEventListener);
        expect(betterPlayerMockController.eventListeners.length, 1);
      });
    },
  );
}
