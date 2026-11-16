import info


class subinfo(info.infoclass):
    def setTargets(self):
        # Modified by ChaeumAI Inc. on 2026-11-16: blueprints come from the Chaeum Drive fork.
        for ver in ["main", "chaeum"]:
            self.svnTargets[ver] = "[git]https://github.com/ceo-chaeum-ai/craft-blueprints-opencloud.git|chaeum|"
        self.defaultTarget = "chaeum"

    def setDependencies(self):
        self.buildDependencies["craft/craft-core"] = "default"


from Package.SourceOnlyPackageBase import *


class Package(SourceOnlyPackageBase):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.subinfo.options.package.disableBinaryCache = True
        self.subinfo.options.dailyUpdate = True

    def unpack(self):
        return True

    def install(self):
        return True

    def qmerge(self):
        if not SourceOnlyPackageBase.qmerge(self):
            return False
        CraftCore.cache.clear()
        return True

    def createPackage(self):
        return True

    def checkoutDir(self, index=0):
        return CraftCore.standardDirs.blueprintRoot() / self.package.name
