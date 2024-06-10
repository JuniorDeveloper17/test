
class KameraPriviewRegisterFacePage extends ConsumerWidget {
  const KameraPriviewRegisterFacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerFace = ref.watch(registerFaceProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: registerFace.isCameraInitialized == false
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  width: MediaQuery.of(context).size.width,
                  child: AspectRatio(
                    aspectRatio:
                        1 / registerFace.cameraController!.value.aspectRatio,
                    child: AspectRatio(
                        aspectRatio: 1 /
                            registerFace.cameraController!.value.aspectRatio,
                        child: CameraPreview(registerFace.cameraController!)),
                  ),
                ),
                SizedBox(
                  height: registerFace.size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SizedBox(
                      width: registerFace.size.width,
                      height: registerFace.size.height,
                      child: registerFace.scanResult.isEmpty
                          ? const Center(
                              child: Text('Camera is not initialized'))
                          : buildPainter(registerFace.cameraController!,
                              registerFace.scanResult, registerFace.camDir)),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          if (registerFace.faces.isNotEmpty) {
            context.push(RouteName.registerFaceSave, extra: {
              'listRecognizenModel': registerFace.scanResult.last,
              'croppedFace': registerFace.croppedFace
            });
          }
        },
        backgroundColor:
            registerFace.faces.isEmpty ? Colors.red : Colors.lightBlue,
      ),
    );
  }

  Widget buildPainter(CameraController cameraController,
      List<RecognizenModel> scanResult, CameraLensDirection camDir) {
    final Size imageSize = Size(
      cameraController.value.previewSize!.height,
      cameraController.value.previewSize!.width,
    );
    CustomPainter painter = FaceDetectorPainter(imageSize, scanResult, camDir);
    return CustomPaint(
      painter: painter,
    );
  }
}
