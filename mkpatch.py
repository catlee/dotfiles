import os, hashlib

from mercurial import commands, util
from hgext import mq

def mkpatch(ui, repo, *pats, **opts):
    """Saves the current patch to a file called <patch_name>-<repo_name>.patch
    in your patch directory (defaults to ~/patches)
    """
    repo_name = os.path.basename(ui.config('paths', 'default'))
    if opts.get('patchdir'):
        patch_dir = opts.get('patchdir')
        del opts['patchdir']
    else:
        patch_dir = os.path.expanduser(ui.config('mkpatch', 'patchdir', "~/patches"))

    if not os.path.exists(patch_dir):
        os.makedirs(patch_dir)
    elif not os.path.isdir(patch_dir):
        raise util.Abort("%s is not a directory" % patch_dir)

    ui.pushbuffer()
    mq.top(ui, repo)
    patch_name = ui.popbuffer().strip()

    if patch_name == 'no patches applied':
        # Try pdiff
        ui.pushbuffer()
        commands.branch(ui, repo)
        patch_name = ui.popbuffer().strip()

        ui.pushbuffer()

        commands.table['^pdiff'][0](ui, repo, *pats, **opts)
    else:
        ui.pushbuffer()
        mq.diff(ui, repo, *pats, **opts)
    patch_data = ui.popbuffer()
    patch_hash = hashlib.new('sha1', patch_data).digest()

    full_name = os.path.join(patch_dir, "%s-%s.patch" % (patch_name, repo_name))
    i = 0
    while os.path.exists(full_name):
        file_hash = hashlib.new('sha1', open(full_name).read()).digest()
        if file_hash == patch_hash:
            ui.status("Patch is identical to ", full_name, "; not saving\n")
            return
        full_name = os.path.join(patch_dir, "%s-%s.patch.%i" % (patch_name, repo_name, i))
        i += 1

    open(full_name, "w").write(patch_data)
    ui.status("Patch saved to ", full_name, "\n")

mkpatch_options = [
        ("", "patchdir", '', "patch directory"),
        ]
cmdtable = {
    "mkpatch": (mkpatch, mkpatch_options + mq.cmdtable['^qdiff'][1], "hg mkpatch [OPTION]... [FILE]...")
}
