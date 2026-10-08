class Result<Ok, Err> {
    final Ok? data;
    final Err? error;

    bool get isError => error != null;
    bool get isOk => error == null;

    Result._({this.data, this.error});

    factory Result.ok(Ok data) => Result._(data: data);
    factory Result.error(Err error) => Result._(error: error);
}

enum ApiError {
  timedOut,
  invalidSession,
  expiredAccessToken,
  invalidEmailOrPassword,
  signUpError,
  noPermission,
  badRequest,
  serverError,
}

typedef ApiRequest<Ok> = Future<Result<Ok, ApiError>>;

