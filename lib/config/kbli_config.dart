class KbliItem {
  final String code;
  final String name;
  final String type; // 'B2B' atau 'Eceran'
  const KbliItem(this.code, this.name, this.type);
}

const List<KbliItem> kbliList = [
  KbliItem('46322', 'Perdagangan Besar Daging Ayam dan Olahan', 'B2B'),
  KbliItem('46206', 'Perdagangan Besar Hasil Perikanan', 'B2B'),
  KbliItem('47754', 'Perdagangan Eceran Pakan Ternak/Ikan', 'Eceran'),
  KbliItem('47245', 'Perdagangan Eceran Daging dan Ikan Olahan', 'Eceran'),
];