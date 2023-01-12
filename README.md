# anki-addon-dev-template
VSCode dev setup for Anki add-ons.

## Notes
The `requirements.txt` file is not needed when you just want to copy over the files to your ankihub add-on folder. It is just here so that this setup can be tested standalone (without adding extra files or copying it into another project).

To test this setup standalone:
- create a new python virtual environment and install the packages listed in `requirements.txt` to it
- use the `Python: Select interpreter` VSCode action to set the python interpreter to the one in the just created virtual environemnt
- adjust the paths in `vscode/launch.json`, `addon.code-workspace` and the symlink at `anki_base/addons21/ankihub` to make it work with your setup
- start Anki in debug mode as shown in the video below

To use this setup with the ankihub add-on, just copy all files (except for `requirements.txt` and `ankihub/__init__.py`) into your ankihub add-on folder and adjust the paths and the symlink mentioned above.


## Screenshots and recordings
<img src="https://user-images.githubusercontent.com/31575114/212190695-3b80024e-2de5-4a5b-ba7e-921a65ad365c.png" width=500>

<img src="https://user-images.githubusercontent.com/31575114/212190704-170d6d4c-945e-4be2-8607-d585e86e31de.png" width=500>


https://user-images.githubusercontent.com/31575114/212191360-8b0ac939-5da0-4b32-bacc-8959579b6d3b.mp4

