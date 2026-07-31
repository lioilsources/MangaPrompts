// Platform seam for rendering an image from a local file path: `Image.file`
// on io, an error placeholder on web (where local paths don't exist).
export 'local_image_stub.dart' if (dart.library.io) 'local_image_io.dart';
