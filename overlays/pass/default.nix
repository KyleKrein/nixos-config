_: (final: prev: {
  pass = prev.pass.withExtensions (exts:
    with exts; [
      pass-otp
      pass-import
    ]);
})
