save.registerID(200001)
save.createSavDir("Setup")
lang = menu.doMenu("Language",{"English"})
settings.set("sys.language",lang)
shell.run("set","setup.done","true")