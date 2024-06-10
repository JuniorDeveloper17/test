class RegisterFaceNotifier extends ChangeNotifier {
  RegisterFaceNotifier() {
    initState();
  }

  CameraController? cameraController;  //dipantau oleh widget
  bool isCameraInitialized = false;  //dipantau oleh widget
  RecognizenService? recognizenService;

  void initState() async {
    try {
      recognizenService = RecognizenService();
      final description = await availableCameras();
      cameraController = CameraController(
        description[1],
        ResolutionPreset.high,
      );
      await cameraController!.initialize();
      isCameraInitialized = cameraController!.value.isInitialized;
      notifyListeners();
      streamKamera();
    } catch (e) {
      initState();
    }
  }

  CameraLensDirection camDir = CameraLensDirection.front;

  bool isBusy = false;  //dipantau oleh widget
  List<Face> faces = <Face>[];  //dipantau oleh widget
  Size size = const Size(0, 0);  //dipantau oleh widget
  List<RecognizenModel> scanResult = []; //dipantau oleh widget
  img.Image? croppedFace;  //dipantau oleh widget

  void streamKamera() async {
    if (isCameraInitialized == true) {
      size = cameraController!.value.previewSize!;
      cameraController!.startImageStream(
        (image) async {
          if (!isBusy) {
            isBusy = true;
            await Future.delayed(const Duration(seconds: 1));
            final inputImage =
                recognizenService!.getInputImage(image, cameraController!);
            faces = await recognizenService!.faceDetectors(inputImage);
            final result =
                recognizenService!.performFaceDetection(image, faces, camDir);
            scanResult = result['listRecognizenModel'];
            croppedFace = result['croppedFace'];
            isBusy = false;
            notifyListeners();
          }
        },
      );
    } else {
      initState();
    }
  }

  void stopStreamKamera() async {
    await cameraController!.stopImageStream();
  }

  @override
  void dispose() {
    stopStreamKamera();
    cameraController?.dispose();
    super.dispose();
  }
}

final registerFaceProvider =
    ChangeNotifierProvider((ref) => RegisterFaceNotifier());
