#' Expectation: does the object inherit from a S3 or S4 class, or a base type?
#'
#' Tests whether or not an object inherits from any of a list of classes, or
#' is an instance of a base type. `expect_null()` is a special case designed
#' for detecting `NULL`.
#'
#' `expect_is()` is an older form. I'd recommend using `expect_s3_class()`
#' or `expect_s4_class()` in order to more clearly convey intent.
#'
#' @inheritParams expect_that
#' @seealso [inherits()]
#' @family expectations
#' @examples
#' expect_is(1, "numeric")
#' a <- matrix(1:10, nrow = 5)
#' expect_is(a, "matrix")
#'
#' expect_is(mtcars, "data.frame")
#' # alternatively for classes that have an is method
#' expect_true(is.data.frame(mtcars))
#'
#' f <- factor("a")
#' expect_is(f, "factor")
#' expect_s3_class(f, "factor")
#' expect_type(f, "integer")
#'
#' expect_null(NULL)
#'
#' @name inheritance-expectations
NULL

#' @export
#' @rdname inheritance-expectations
expect_null <- function(object, info = NULL, label = NULL) {
  lab <- make_label(object, label)

  expect(
    is.null(object),
    sprintf("%s is not null.", lab),
    info = info
  )
  invisible(object)
}

#' @export
#' @rdname inheritance-expectations
expect_type <- function(object, type) {
  stopifnot(is.character(type), length(type) == 1)

  lab <- make_label(object)
  act <- typeof(object)
  exp <- type

  expect(
    identical(type, act),
    sprintf("%s has type `%s`, not `%s`.", lab, act, exp)
  )
  invisible(object)
}

#' @param class character vector of class names
#' @param type String giving base type (as returned by [typeof()]).
#' @export
#' @rdname inheritance-expectations
expect_is <- function(object, class, info = NULL, label = NULL) {
  stopifnot(is.character(class))

  lab <- make_label(object, label)
  act <- klass(object)
  exp <- paste(class, collapse = "/")

  expect(
    inherits(object, class),
    sprintf("%s inherits from `%s` not `%s`.", lab, act, exp),
    info = info
  )
  invisible(object)
}

#' @export
#' @rdname inheritance-expectations
expect_s3_class <- function(object, class) {
  stopifnot(is.character(class))

  lab <- label(object)
  act <- klass(object)
  exp <- paste(class, collapse = "/")

  if (!isS3(object)) {
    fail(sprintf("%s is not an S3 object", lab))
  }

  expect(
    inherits(object, class),
    sprintf("%s inherits from `%s` not `%s`.", lab, act, exp)
  )
  invisible(object)
}

#' @export
#' @rdname inheritance-expectations
expect_s4_class <- function(object, class) {
  stopifnot(is.character(class))

  lab <- label(object)
  act <- paste(methods::is(object), collapse = "/")
  exp <- paste(class, collapse = "/")

  if (!isS4(object)) {
    fail(sprintf("%s is not an S4 object", lab))
  }

  expect(
    methods::is(object, class),
    sprintf("%s inherits from `%s` not `%s`.", lab, act, exp)
  )
  invisible(object)
}

isS3 <- function(x) is.object(x) && !isS4(x)
