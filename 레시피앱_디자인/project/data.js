// 원가계산기 — Seed data
// All prices in KRW, weights in standard units.

window.SEED_INGREDIENTS = [
  { id: 'i1',  name: '돼지 삼겹살',     unit: 'g',   price: 28,    stock: 4200,  expiry: '2026-05-09', category: '육류' },
  { id: 'i2',  name: '소 등심',        unit: 'g',   price: 64,    stock: 1800,  expiry: '2026-05-07', category: '육류' },
  { id: 'i3',  name: '닭가슴살',       unit: 'g',   price: 14,    stock: 5600,  expiry: '2026-05-12', category: '육류' },
  { id: 'i4',  name: '양파',          unit: 'g',   price: 3.2,   stock: 12000, expiry: '2026-05-22', category: '채소' },
  { id: 'i5',  name: '대파',          unit: 'g',   price: 6.8,   stock: 3400,  expiry: '2026-05-08', category: '채소' },
  { id: 'i6',  name: '마늘',          unit: 'g',   price: 18,    stock: 1500,  expiry: '2026-06-01', category: '채소' },
  { id: 'i7',  name: '청양고추',       unit: 'g',   price: 22,    stock: 800,   expiry: '2026-05-06', category: '채소' },
  { id: 'i8',  name: '간장',          unit: 'ml',  price: 4.5,   stock: 8500,  expiry: '2027-02-01', category: '조미료' },
  { id: 'i9',  name: '설탕',          unit: 'g',   price: 2.4,   stock: 6200,  expiry: '2027-08-15', category: '조미료' },
  { id: 'i10', name: '고춧가루',       unit: 'g',   price: 38,    stock: 2200,  expiry: '2026-09-30', category: '조미료' },
  { id: 'i11', name: '참기름',        unit: 'ml',  price: 22,    stock: 1200,  expiry: '2026-12-20', category: '조미료' },
  { id: 'i12', name: '식용유',        unit: 'ml',  price: 3.8,   stock: 9000,  expiry: '2026-11-30', category: '조미료' },
  { id: 'i13', name: '계란',          unit: '개',   price: 380,   stock: 80,    expiry: '2026-05-14', category: '유제품' },
  { id: 'i14', name: '두부',          unit: 'g',   price: 5.2,   stock: 2400,  expiry: '2026-05-06', category: '채소' },
  { id: 'i15', name: '쌀',           unit: 'g',   price: 4.1,   stock: 18000, expiry: '2026-12-31', category: '곡물' },
];

window.SEED_SAUCES = [
  {
    id: 's1', name: '제육 양념',
    items: [
      { ingId: 'i8',  qty: 30 },   // 간장 30ml
      { ingId: 'i9',  qty: 15 },   // 설탕 15g
      { ingId: 'i10', qty: 12 },   // 고춧가루 12g
      { ingId: 'i6',  qty: 8 },    // 마늘 8g
      { ingId: 'i11', qty: 4 },    // 참기름 4ml
    ],
  },
  {
    id: 's2', name: '간장 베이스',
    items: [
      { ingId: 'i8',  qty: 50 },
      { ingId: 'i9',  qty: 8 },
      { ingId: 'i6',  qty: 4 },
      { ingId: 'i11', qty: 3 },
    ],
  },
  {
    id: 's3', name: '매운 양념장',
    items: [
      { ingId: 'i10', qty: 18 },
      { ingId: 'i7',  qty: 10 },
      { ingId: 'i6',  qty: 6 },
      { ingId: 'i8',  qty: 12 },
    ],
  },
];

window.SEED_RECIPES = [
  {
    id: 'r1', name: '제육볶음', servings: 1, sellPrice: 9500, image: '🥘',
    ingredients: [
      { ingId: 'i1', qty: 180 },  // 삼겹살
      { ingId: 'i4', qty: 60 },   // 양파
      { ingId: 'i5', qty: 30 },   // 대파
      { ingId: 'i12', qty: 10 },  // 식용유
    ],
    sauces: [{ sauceId: 's1', qty: 1 }],
  },
  {
    id: 'r2', name: '닭가슴살 덮밥', servings: 1, sellPrice: 8000, image: '🍚',
    ingredients: [
      { ingId: 'i3', qty: 150 },
      { ingId: 'i15', qty: 200 },
      { ingId: 'i13', qty: 1 },
      { ingId: 'i5', qty: 15 },
    ],
    sauces: [{ sauceId: 's2', qty: 1 }],
  },
  {
    id: 'r3', name: '계란말이', servings: 1, sellPrice: 4500, image: '🍳',
    ingredients: [
      { ingId: 'i13', qty: 3 },
      { ingId: 'i5', qty: 10 },
      { ingId: 'i12', qty: 5 },
    ],
    sauces: [],
  },
  {
    id: 'r4', name: '소 등심 스테이크', servings: 1, sellPrice: 24000, image: '🥩',
    ingredients: [
      { ingId: 'i2', qty: 200 },
      { ingId: 'i6', qty: 5 },
      { ingId: 'i12', qty: 8 },
    ],
    sauces: [{ sauceId: 's3', qty: 1 }],
  },
];

// 가격 이력 (price history) — for ingredient detail chart
window.SEED_PRICE_HISTORY = {
  i1: [{ d: '2026-01', p: 24 }, { d: '2026-02', p: 25 }, { d: '2026-03', p: 26 }, { d: '2026-04', p: 27 }, { d: '2026-05', p: 28 }],
  i2: [{ d: '2026-01', p: 58 }, { d: '2026-02', p: 60 }, { d: '2026-03', p: 62 }, { d: '2026-04', p: 65 }, { d: '2026-05', p: 64 }],
  i3: [{ d: '2026-01', p: 16 }, { d: '2026-02', p: 15 }, { d: '2026-03', p: 14 }, { d: '2026-04', p: 13 }, { d: '2026-05', p: 14 }],
  i4: [{ d: '2026-01', p: 2.8 }, { d: '2026-02', p: 3.0 }, { d: '2026-03', p: 3.5 }, { d: '2026-04', p: 3.4 }, { d: '2026-05', p: 3.2 }],
};

// Helpers
window.fmtKRW = (n) => '₩' + Math.round(n).toLocaleString('ko-KR');
window.fmtKRWdec = (n) => '₩' + (Math.round(n * 10) / 10).toLocaleString('ko-KR');
