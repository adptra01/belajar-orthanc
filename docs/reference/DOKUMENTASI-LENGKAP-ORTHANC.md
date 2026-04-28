# Panduan Lengkap Orthanc DICOM Server — Index

> **Dokumen ini adalah index/ringkasan.** Konten detail tersedia di file-file sumber terpisah untuk menghindari duplikasi dan memudahkan pemeliharaan.

## Dokumen Sumber (Source of Truth)

| File | Topik |
|------|-------|
| [DOKUMENTASI-ORTHANC.md](./DOKUMENTASI-ORTHANC.md) | Pengenalan, instalasi, konfigurasi, web interface, REST API, troubleshooting |
| [PLUGIN-ORTHANC-DETAILED.md](./PLUGIN-ORTHANC-DETAILED.md) | Plugin, konfigurasi lanjutan, API plugin, optimasi performa |
| [TUTORIAL-ORTHANC-WEB.md](./TUTORIAL-ORTHANC-WEB.md) | Web interface lengkap: viewer, export, search, workflows |
| [ORTHANC-CHEAT-SHEET.md](./ORTHANC-CHEAT-SHEET.md) | Referensi cepat perintah, API, konfigurasi, troubleshooting |
| [ORTHANC-FOR-BEGINNERS-COMPLETE.md](./ORTHANC-FOR-BEGINNERS-COMPLETE.md) | Panduan pemula: planning hingga deployment online |
| [ORTHANC-API-REFERENCE.md](./ORTHANC-API-REFERENCE.md) | Dokumentasi REST API lengkap dengan contoh teruji |
| [orthanc-website-integration.md](../plan/orthanc-website-integration.md) | Panduan integrasi Orthanc dengan website kustom |

## Panduan Setup Bertahap

[Orthanc-Complete-Setup-Guide/](../guide/) — 15 bagian:

| Bagian | Topik | Sumber |
|--------|-------|--------|
| [01-Spesifikasi-Sistem.md](../guide/01-Spesifikasi-Sistem.md) | Hardware, software, resource | Asli |
| [02-Alat-dan-Perlengkapan.md](../guide/02-Alat-dan-Perlengkapan.md) | Tools checklist, environment | Asli |
| [03-Konfigurasi-Jaringan.md](../guide/03-Konfigurasi-Jaringan.md) | Local network, port forwarding, firewall | Asli |
| [04-Dokumentasi-API.md](../guide/04-Dokumentasi-API.md) | REST API endpoints & contoh | Asli |
| [05-Memasang-Plugin.md](../guide/05-Memasang-Plugin.md) | Plugin installation & config | Asli |
| [06-Konfigurasi-PACS.md](../guide/06-Konfigurasi-PACS.md) | DICOM networking, SCP/SCU, routing | Asli |
| [07-Konfigurasi-Inti-Orthanc.md](../guide/07-Konfigurasi-Inti-Orthanc.md) | Config file, database, optimization | Asli |
| [08-Akses-Lokal.md](../guide/08-Akses-Lokal.md) | Localhost & LAN access | Asli |
| [09-Akses-Online-Remote.md](../guide/09-Akses-Online-Remote.md) | Cloudflare, SSL/TLS, security | Asli |
| [10-Troubleshooting.md](../guide/10-Troubleshooting.md) | Common issues, recovery | Asli |
| [11-Panduan-Lengkap-Orthanc.md](../guide/11-Panduan-Lengkap-Orthanc.md) | → Lihat [DOKUMENTASI-ORTHANC.md](./DOKUMENTASI-ORTHANC.md) |
| [12-Referensi-Cepat-Orthanc.md](../guide/12-Referensi-Cepat-Orthanc.md) | → Lihat [ORTHANC-CHEAT-SHEET.md](./ORTHANC-CHEAT-SHEET.md) |
| [13-Guide-Plugin-Lengkap.md](../guide/13-Guide-Plugin-Lengkap.md) | → Lihat [PLUGIN-ORTHANC-DETAILED.md](./PLUGIN-ORTHANC-DETAILED.md) |
| [14-Guide-Web-Interface.md](../guide/14-Guide-Web-Interface.md) | → Lihat [TUTORIAL-ORTHANC-WEB.md](./TUTORIAL-ORTHANC-WEB.md) |
| [15-Setup-Lengkap-Pemula.md](../guide/15-Setup-Lengkap-Pemula.md) | → Lihat [ORTHANC-FOR-BEGINNERS-COMPLETE.md](./ORTHANC-FOR-BEGINNERS-COMPLETE.md) |

## Cara Penggunaan

1. **Pemula**: Mulai dari [01-Spesifikasi-Sistem.md](../guide/01-Spesifikasi-Sistem.md) lanjut ke 02-10
2. **Referensi cepat**: [ORTHANC-CHEAT-SHEET.md](./ORTHANC-CHEAT-SHEET.md)
3. **Web interface**: [TUTORIAL-ORTHANC-WEB.md](./TUTORIAL-ORTHANC-WEB.md)
4. **Plugin & advanced**: [PLUGIN-ORTHANC-DETAILED.md](./PLUGIN-ORTHANC-DETAILED.md)
5. **Perencanaan proyek**: [ORTHANC-FOR-BEGINNERS-COMPLETE.md](./ORTHANC-FOR-BEGINNERS-COMPLETE.md)

## Resources

- [Orthanc Book](https://orthanc.uclouvain.be/book/)
- [REST API Reference](https://orthanc.uclouvain.be/book/developers/rest.html)
- [Plugin Documentation](https://orthanc.uclouvain.be/book/developers/plugins/)
- [Orthanc Forum](https://www.orthanc-server.com/forum/)
- [Docker Hub — orthanc-plugins](https://hub.docker.com/r/jodogne/orthanc-plugins/)
