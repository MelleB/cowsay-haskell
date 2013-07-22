
Cowsay
======
A cowsay implementation in Haskell. Based on the original cowsay implementation
of [Tony Monroe](http://www.nog.net/~tony/warez/cowsay-3.03.tar.gz), inspired
by [@advi](https://github.com/avdi).

Did you know there's even a [Wiki](http://en.wikipedia.org/wiki/Cowsay)
on cowsay?


Usage
-----
    $ cowsay -h
    Usage: cowsay [OPTIONS] [MESSAGE]
      -l         --list           List available cows
      -f FILE    --file=FILE      Set cow type
      -W WIDTH   --width=WIDTH    Set max message width
      -b         --borg           Borg cow mode
      -d         --dead           Dead cow mode
      -g         --greedy         Greedy cow mode
      -p         --paranoid       Paranoid cow mode
      -s         --stoned         Stoned cow mode
      -t         --tired          Tired cow mode
      -w         --wired          Wired cow mode
      -y         --young          Young cow mode
      -e EYES    --eyes=EYES      Set cow eyes
      -T TONGUE  --tongue=TONGUE  Set cow tongue


    $ ./cowsay -e "^^" -f small Moooooooooooooooooooo!
     ________________________
    < Moooooooooooooooooooo! >
     ------------------------
           \   ,__,
            \  (^^)____
               (__)    )\\
                  ||--|| *


TODO
----
The following functionality is lacking compared to the original version:
 - Being able to read from stdin
 - Disable word wrapping (the `-n` flag)


License
-------
Distributed under the original cowsay license, please see the
[LICENSE](LICENSE) file.

