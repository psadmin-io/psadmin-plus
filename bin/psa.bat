@ECHO OFF
REM This executes the psa ruby script from this directory with parameters via ruby.exe
REM Add <psa_dir>\bin to PATH for use when running psa directly, without gem install
@ruby.exe "%~dpn0" %*