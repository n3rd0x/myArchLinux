# Global variables.
sdboot=/dev/nvme0n1p1
sddata=/dev/nvme0n1p2
sdswap=/dev/nvme0n1p3
sdroot=/dev/nvme0n1p4
rddata=luksData
rdswap=luksSwap
rdroot=luksRoot
dmdata=/dev/mapper/${rddata}
dmswap=/dev/mapper/${rdswap}
dmroot=/dev/mapper/${rdroot}
