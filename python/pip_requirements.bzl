def _pip_import_requirements_impl(repository_ctx):
  """Core implementation of pip_import."""
  # Add an empty top-level BUILD file.
  # This is because Bazel requires BUILD files along all paths accessed
  # via //this/sort/of:path and we wouldn't be able to load our generated
  # requirements.bzl without it.
  repository_ctx.file("BUILD", "")

  inputs = []
  for r in repository_ctx.attr.requirements:
    inputs += ["--input", repository_ctx.path(r)]
  # To see the output, pass: quiet=False
  result = repository_ctx.execute([
    "python3", repository_ctx.path(repository_ctx.attr._script),
    "--name", repository_ctx.attr.name,
    ] + inputs + [
      "--output", repository_ctx.path("requirements.bzl"),
      "--directory", repository_ctx.path("")
    ],
  quiet = repository_ctx.attr.quiet)

  if result.return_code:
    fail("pip_import failed: %s (%s)" % (result.stdout, result.stderr))


pip_import_requirements = repository_rule(
  attrs = {
    "quiet" : attr.bool(default = False),
    "requirements": attr.label_list(
       allow_files = True,
       mandatory = True,
     ),
     "_script": attr.label(
       executable = True,
       default = Label("@io_bazel_rules_python//tools:piptool.par"),
       cfg = "host",
     ),
  },
  implementation = _pip_import_requirements_impl,
)
