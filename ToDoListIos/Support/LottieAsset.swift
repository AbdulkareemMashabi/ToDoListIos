import Foundation

enum LottieAsset: String {
    case splash
    case done = "doneLottie"
    case loadingButton

    var filepath: String {
        Bundle.main.path(forResource: rawValue, ofType: "json") ?? ""
    }
}
