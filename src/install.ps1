$knife = "# Empty knife config"
[IO.File]::WriteAllLines("knife.rb", $knife)
$windows = 'windows.tar.gz'
knife supermarket download windows -f $windows
tar.exe -xf $windows
mv .\windows\ .\cookbooks\
del $windows
