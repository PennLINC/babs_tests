This markdown file describes how `datalad containers-run` works, esp re: `call-fmt` in `datalad containers-add`.

# Where is the information `call-fmt` saved?

* source code of `datalad containers-add`: [here](https://github.com/datalad/datalad-container/blob/master/datalad_container/containers_add.py#L168)
* It should in: `<container_dataset>/.datalad/config`; just `cat` this config file and see. For more, please check out the jupyter notebook: `how_datalad_containers_add_call-fmt.ipynb`.
    * There will be a key called `cmdexec`. Under what conditions will this be set?
        * When `call-fmt` was flagged when `datalad containers-add
        * If it's not provided, when the container's url starts with `shub://` or `dhub://`, datalad will also make a guess of the `call-fmt`,
    * Then, the `call-fmt` will be saved as a key called `cmdexec` (source code [here](https://github.com/datalad/datalad-container/blob/master/datalad_container/containers_add.py#L319))
        * If loading it into python, you can get a `dict` object.
    
* How to find the full list of config files:

```python
# conda activate mydatalad

from datalad.distribution.dataset import require_dataset

ds = require_dataset("<path to container dataset>", check_installed=True, purpose='add container')
# ^^ ds is a Dataset, e.g., `Dataset('<path to container dataset>')`

ds.config
# will list all the config file paths
```

# How this `call-fmt` information is incorporated in `datalad containers-run`?

* The source code of `datalad containers-run`: [this](http://docs.datalad.org/projects/container/en/latest/_modules/datalad_container/containers_run.html#ContainersRun)
    * This is [the link of the code on github](https://github.com/datalad/datalad-container/blob/master/datalad_container/containers_run.py)

* Logic flow of using `call-fmt`:
    * It will first check `if 'cmdexec' in container`; if so, it will use `container['cmdexec']` and generate the appropriate commands
    * If not, it will make a guess: `cmd = container['path'] + ' ' + cmd`
        * example `container['path']`: `pennlinc-containers/.datalad/environments/qsiprep-0-16-0RC3/image'`
* After necessary command is set up, it will `run_command()` (a function from `datalad.core.local.run`)