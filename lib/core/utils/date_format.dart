/// Formatos de fecha cortos en español sin depender de `intl`.
library;

const _dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const _meses = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// Ej.: `Sáb 31 oct`.
String fechaCorta(DateTime fecha) =>
    '${_dias[fecha.weekday - 1]} ${fecha.day} ${_meses[fecha.month - 1]}';

/// Ej.: `31 oct 2026`.
String fechaLarga(DateTime fecha) =>
    '${fecha.day} ${_meses[fecha.month - 1]} ${fecha.year}';
