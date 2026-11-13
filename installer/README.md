# VÁGÁNYMESTER – WPF telepítő

Valódi Inno Setup Windows .exe, nem ZIP vagy Visual Studio-projekt.
A wpf-installer.yml automatikusan lefordítja, majd GitHub Actions-be feltölti.

Tulajdonságok:
- Windows 10/11, 64 bit
- Beépített .NET 8 Desktop Runtime, nincs szükség Visual Studióra
- Saját profilba telepít, rendszergazdai jogosultság nélkül
- Modern, sötét, saját grafikus üdvözlőképernyő és saját ikon
- Magyar / angol / német nyelv, Start menü, választható asztali ikon
- Indítás a telepítés végén, eltávolítás Windows Beállításokból
- SHA-256 ellenőrzőösszeg, LZMA2 tömörítés

Windows alatt:
1. pip install Pillow==11.3.0
2. python installer/generate_assets.py
3. dotnet publish Vaganymester/Vaganymester.csproj -c Release -r win-x64 --self-contained true --output artifacts/publish /p:PublishSingleFile=true /p:IncludeNativeLibrariesForSelfExtract=true
4. ISCC.exe installer/Vaganymester.iss

A telepítő Authenticode aláírás nélküli tesztverzió; ezért a Windows
SmartScreen figyelmeztethet. A telepítő a meglévő WPF-programot
tartalmazza, nem a Flutter mobiljáték PC-s portját.
