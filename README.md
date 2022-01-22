# dotfiles

Reference [Atlassian git tutorials](https://www.atlassian.com/git/tutorials/dotfiles)

## Set up for new hosts
```bash
git clone --bare git@github.com:fmirkes/dotfiles.git .dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout
source .zshrc
dotfiles config --local status.showUntrackedFiles no
```
