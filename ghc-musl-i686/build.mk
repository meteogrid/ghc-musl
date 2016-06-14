V = 0
GhcLibWays = v dyn p
DYNAMIC_TOO      = YES
SRC_HC_OPTS     = -O -H64m -optl--no-pie
GhcStage1HcOpts = -O  $(GhcFAsm)
GhcStage2HcOpts = -O2  $(GhcFAsm)
GhcHcOpts       = -Rghc-timing
GhcLibHcOpts    = -O2
