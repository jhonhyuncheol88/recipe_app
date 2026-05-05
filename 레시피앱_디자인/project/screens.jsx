/* global React, Icon, Button, Field, Input, Badge, Card, Sheet, Segment,
   useToast, Sparkline, BarStack, Donut, VBars, AppBar, Stat,
   SEED_INGREDIENTS, SEED_SAUCES, SEED_RECIPES, SEED_PRICE_HISTORY,
   fmtKRW, fmtKRWdec */
const { useState, useEffect, useMemo, useRef } = React;

// ── Cost calculation helpers ──────────────────────────────
const calcSauceCost = (sauce, ingredients) => {
  return sauce.items.reduce((sum, it) => {
    const ing = ingredients.find((i) => i.id === it.ingId);
    return sum + (ing ? ing.price * it.qty : 0);
  }, 0);
};
const calcRecipeCost = (recipe, ingredients, sauces) => {
  const ingCost = recipe.ingredients.reduce((sum, it) => {
    const ing = ingredients.find((i) => i.id === it.ingId);
    return sum + (ing ? ing.price * it.qty : 0);
  }, 0);
  const sauceCost = recipe.sauces.reduce((sum, it) => {
    const s = sauces.find((x) => x.id === it.sauceId);
    return sum + (s ? calcSauceCost(s, ingredients) * it.qty : 0);
  }, 0);
  return ingCost + sauceCost;
};
const margin = (sellPrice, cost) => sellPrice > 0 ? ((sellPrice - cost) / sellPrice) * 100 : 0;
const daysUntil = (dateStr) => {
  const d = new Date(dateStr);
  const today = new Date('2026-05-04');
  return Math.round((d - today) / (1000 * 60 * 60 * 24));
};
window.calcSauceCost = calcSauceCost;
window.calcRecipeCost = calcRecipeCost;
window.margin = margin;
window.daysUntil = daysUntil;

/* ──────────────────────────────────────────────────────────
   HOME — dashboard
   ────────────────────────────────────────────────────────── */
const HomeScreen = ({ state, setRoute }) => {
  const { ingredients, sauces, recipes } = state;
  // Calculate metrics
  const inventoryValue = ingredients.reduce((s, i) => s + i.price * i.stock, 0);
  const expiringSoon = ingredients.filter((i) => {
    const d = daysUntil(i.expiry);
    return d >= 0 && d <= 3;
  });
  const avgMargin = recipes.length
    ? recipes.reduce((s, r) => s + margin(r.sellPrice, calcRecipeCost(r, ingredients, sauces)), 0) / recipes.length
    : 0;
  const topRecipe = recipes
    .map((r) => ({ ...r, marginPct: margin(r.sellPrice, calcRecipeCost(r, ingredients, sauces)) }))
    .sort((a, b) => b.marginPct - a.marginPct)[0];

  const week = [
    { label: '월', v: 142 },
    { label: '화', v: 168 },
    { label: '수', v: 195 },
    { label: '목', v: 178 },
    { label: '금', v: 224, highlight: true },
    { label: '토', v: 0 },
    { label: '일', v: 0 },
  ];

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <div style={{ padding: '60px 16px 0', background: '#fff' }}>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', height: 40 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{
              width: 28, height: 28, borderRadius: 8,
              background: 'var(--primary)', color: '#fff',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              font: '800 14px/1 var(--font-sans)',
            }}>원</div>
            <div style={{ font: '700 15px/1.3 var(--font-sans)', letterSpacing: '-0.01em' }}>원가계산기</div>
          </div>
          <div style={{ display: 'flex', gap: 4 }}>
            <button style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-strong)', position: 'relative' }}>
              <Icon name="bell" size={22} />
              <span style={{ position: 'absolute', top: 6, right: 6, width: 6, height: 6, background: 'var(--negative)', borderRadius: 999 }} />
            </button>
            <button style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-strong)' }}>
              <Icon name="settings" size={22} />
            </button>
          </div>
        </div>
        <div style={{ padding: '14px 0 18px' }}>
          <div style={{ font: '500 13px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginBottom: 4 }}>
            안녕하세요, 김셰프 님
          </div>
          <div style={{ font: '700 24px/1.3 var(--font-sans)', letterSpacing: '-0.022em', color: 'var(--fg-strong)' }}>
            오늘 평균 마진율<br />
            <span style={{ color: 'var(--primary)' }}>{avgMargin.toFixed(1)}%</span>
            <span style={{ font: '500 14px/1 var(--font-sans)', color: 'var(--fg-tertiary)', marginLeft: 8 }}>
              ↑ 1.4%p 어제 대비
            </span>
          </div>
        </div>
      </div>

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* KPI grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <Stat label="재고 가치" value={fmtKRW(inventoryValue)} delta="3.2%" deltaTone="positive" sub="전주 대비" icon="package" />
          <Stat label="등록 레시피" value={`${recipes.length}개`} sub={`소스 ${sauces.length}개`} icon="chef" iconBg="rgba(101,65,242,0.1)" style={{ '--icon-color': 'var(--accent-ai)' }} />
          <Stat label="평균 원가율" value={`${(100 - avgMargin).toFixed(1)}%`} delta="0.8%p" deltaTone="negative" sub="목표 35%" icon="chart" iconBg="rgba(255,146,0,0.1)" />
          <Stat label="유통기한 임박" value={`${expiringSoon.length}개`} sub="3일 내" icon="alert" iconBg="rgba(255,66,66,0.1)" />
        </div>

        {/* Weekly cost trend */}
        <Card padding={16}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 4 }}>
            <div>
              <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>이번 주 식재료 사용</div>
              <div style={{ font: '700 22px/1.2 var(--font-sans)', letterSpacing: '-0.018em', marginTop: 4 }}>{fmtKRW(907000)}</div>
            </div>
            <Badge tone="positive" size="sm">목표 내 12%</Badge>
          </div>
          <div style={{ marginTop: 12, marginLeft: -4 }}>
            <VBars data={week} w={296} h={80} />
          </div>
        </Card>

        {/* Expiring */}
        {expiringSoon.length > 0 && (
          <Card padding={0} style={{ overflow: 'hidden' }}>
            <div style={{
              padding: '14px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              borderBottom: '1px solid var(--border-subtle)',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <Icon name="alert" size={18} color="var(--negative)" />
                <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>유통기한 임박</div>
              </div>
              <button onClick={() => setRoute({ name: 'ingredients' })}
                style={{ border: 0, background: 'transparent', font: '600 12px/1 var(--font-sans)', color: 'var(--primary)', cursor: 'pointer' }}>
                전체보기
              </button>
            </div>
            {expiringSoon.slice(0, 3).map((ing, i) => {
              const d = daysUntil(ing.expiry);
              return (
                <div key={ing.id} style={{
                  padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
                  borderBottom: i < expiringSoon.slice(0, 3).length - 1 ? '1px solid var(--border-subtle)' : 'none',
                }}>
                  <div>
                    <div style={{ font: '600 14px/1.3 var(--font-sans)', color: 'var(--fg-strong)' }}>{ing.name}</div>
                    <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                      재고 {ing.stock.toLocaleString()}{ing.unit} · {fmtKRW(ing.price * ing.stock)}
                    </div>
                  </div>
                  <Badge tone={d <= 1 ? 'negative' : 'warning'} size="sm">{d === 0 ? '오늘' : `D-${d}`}</Badge>
                </div>
              );
            })}
          </Card>
        )}

        {/* Top recipe */}
        {topRecipe && (
          <Card padding={16} onClick={() => setRoute({ name: 'recipe', id: topRecipe.id })}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                <Icon name="sparkle" size={16} color="var(--accent-ai)" />
                <div style={{ font: '600 13px/1.3 var(--font-sans)', color: 'var(--accent-ai)', letterSpacing: '0.015em' }}>
                  마진율 1위 메뉴
                </div>
              </div>
              <Icon name="chevronRight" size={18} color="var(--fg-tertiary)" />
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 56, height: 56, borderRadius: 14, background: 'var(--bg-muted)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28,
              }}>{topRecipe.image}</div>
              <div style={{ flex: 1 }}>
                <div style={{ font: '700 17px/1.3 var(--font-sans)', letterSpacing: '-0.01em' }}>{topRecipe.name}</div>
                <div style={{ display: 'flex', gap: 12, marginTop: 4 }}>
                  <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
                    원가 <span style={{ color: 'var(--fg-strong)', fontWeight: 600 }}>{fmtKRW(calcRecipeCost(topRecipe, ingredients, sauces))}</span>
                  </div>
                  <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
                    판매가 <span style={{ color: 'var(--fg-strong)', fontWeight: 600 }}>{fmtKRW(topRecipe.sellPrice)}</span>
                  </div>
                </div>
              </div>
              <div style={{ font: '700 22px/1 var(--font-sans)', letterSpacing: '-0.02em', color: 'var(--positive)' }}>
                {topRecipe.marginPct.toFixed(0)}%
              </div>
            </div>
          </Card>
        )}

        {/* Quick actions */}
        <div style={{ font: '700 15px/1.3 var(--font-sans)', color: 'var(--fg-strong)', marginTop: 4 }}>빠른 작업</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <Card padding={16} onClick={() => setRoute({ name: 'ingredient-new' })}>
            <Icon name="plus" size={20} color="var(--primary)" />
            <div style={{ font: '600 14px/1.3 var(--font-sans)', marginTop: 8 }}>재료 등록</div>
            <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>직접 입력</div>
          </Card>
          <Card padding={16} onClick={() => setRoute({ name: 'ocr' })}>
            <Icon name="receipt" size={20} color="var(--accent-ai)" />
            <div style={{ font: '600 14px/1.3 var(--font-sans)', marginTop: 8, display: 'flex', alignItems: 'center', gap: 4 }}>
              영수증 OCR <Badge tone="ai" size="sm">AI</Badge>
            </div>
            <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>일괄 등록</div>
          </Card>
          <Card padding={16} onClick={() => setRoute({ name: 'sauce-new' })}>
            <Icon name="blend" size={20} color="var(--positive)" />
            <div style={{ font: '600 14px/1.3 var(--font-sans)', marginTop: 8 }}>소스 만들기</div>
            <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>재료 조합</div>
          </Card>
          <Card padding={16} onClick={() => setRoute({ name: 'recipe-new' })}>
            <Icon name="chef" size={20} color="var(--warning)" />
            <div style={{ font: '600 14px/1.3 var(--font-sans)', marginTop: 8 }}>레시피 등록</div>
            <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>원가 계산</div>
          </Card>
        </div>

        <div style={{ height: 80 }} />
      </div>
    </div>
  );
};

/* ──────────────────────────────────────────────────────────
   INGREDIENTS LIST + DETAIL
   ────────────────────────────────────────────────────────── */
const IngredientsScreen = ({ state, setRoute, dispatch }) => {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [sortMode, setSortMode] = useState('expiry');

  const filtered = useMemo(() => {
    let list = state.ingredients.filter((i) => !i.deleted);
    if (search) list = list.filter((i) => i.name.includes(search));
    if (filter !== 'all') list = list.filter((i) => i.category === filter);
    if (sortMode === 'expiry') list = [...list].sort((a, b) => daysUntil(a.expiry) - daysUntil(b.expiry));
    if (sortMode === 'price') list = [...list].sort((a, b) => b.price - a.price);
    if (sortMode === 'name') list = [...list].sort((a, b) => a.name.localeCompare(b.name, 'ko'));
    return list;
  }, [state.ingredients, search, filter, sortMode]);

  const cats = ['all', '육류', '채소', '조미료', '유제품', '곡물'];
  const catLabels = { all: '전체', 육류: '육류', 채소: '채소', 조미료: '조미료', 유제품: '유제품', 곡물: '곡물' };

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <div style={{ background: '#fff', position: 'sticky', top: 0, zIndex: 5 }}>
        <AppBar title="재료" large
          subtitle={`${filtered.length}개 · 총 ${fmtKRW(filtered.reduce((s, i) => s + i.price * i.stock, 0))}`}
          trailing={<>
            <button onClick={() => setRoute({ name: 'ocr' })}
              style={{ border: 0, background: 'transparent', padding: 8, cursor: 'pointer', color: 'var(--fg-strong)' }}>
              <Icon name="receipt" size={22} />
            </button>
            <button onClick={() => setRoute({ name: 'ingredient-new' })}
              style={{ border: 0, background: 'var(--primary)', color: '#fff', padding: '6px 12px', borderRadius: 999, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4, font: '600 13px/1 var(--font-sans)' }}>
              <Icon name="plus" size={16} /> 등록
            </button>
          </>}
        />
        <div style={{ padding: '0 16px 12px' }}>
          <Input value={search} onChange={setSearch} placeholder="재료명 검색"
            prefix={<Icon name="search" size={16} color="var(--fg-tertiary)" />} />
        </div>
        <div style={{
          padding: '0 16px 12px', display: 'flex', gap: 6, overflowX: 'auto',
          scrollbarWidth: 'none',
        }}>
          {cats.map((c) => (
            <button key={c} onClick={() => setFilter(c)}
              style={{
                border: 0, padding: '7px 14px', borderRadius: 999, cursor: 'pointer',
                font: '600 13px/1 var(--font-sans)', whiteSpace: 'nowrap',
                background: filter === c ? 'var(--fg-strong)' : 'rgba(112,115,124,0.08)',
                color: filter === c ? '#fff' : 'var(--fg-secondary)',
              }}>{catLabels[c]}</button>
          ))}
        </div>
      </div>

      <div style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
          유통기한 임박순
        </div>
        <button style={{ border: 0, background: 'transparent', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4, color: 'var(--fg-secondary)', font: '600 12px/1 var(--font-sans)' }}>
          <Icon name="sliders" size={14} /> 정렬
        </button>
      </div>

      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {filtered.map((ing) => {
          const d = daysUntil(ing.expiry);
          const tone = d <= 1 ? 'negative' : d <= 3 ? 'warning' : 'neutral';
          return (
            <Card key={ing.id} padding={14} onClick={() => setRoute({ name: 'ingredient', id: ing.id })}
              style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 44, height: 44, borderRadius: 12,
                background: ing.category === '육류' ? '#FEECEC' : ing.category === '채소' ? '#F2FFF6' : ing.category === '조미료' ? '#FEF4E6' : 'var(--bg-muted)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                font: '700 11px/1 var(--font-sans)',
                color: ing.category === '육류' ? '#B20C0C' : ing.category === '채소' ? '#006E25' : ing.category === '조미료' ? '#D47800' : 'var(--fg-secondary)',
              }}>{ing.category}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                  <div style={{ font: '600 15px/1.3 var(--font-sans)', color: 'var(--fg-strong)' }}>{ing.name}</div>
                  {tone !== 'neutral' && <Badge tone={tone} size="sm">D-{d}</Badge>}
                </div>
                <div style={{ font: '500 12px/1.4 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  {fmtKRWdec(ing.price)}/{ing.unit} · 재고 {ing.stock.toLocaleString()}{ing.unit}
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ font: '700 14px/1.3 var(--font-sans)', color: 'var(--fg-strong)' }}>{fmtKRW(ing.price * ing.stock)}</div>
                <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  {ing.expiry.replace(/-/g, '.')}
                </div>
              </div>
            </Card>
          );
        })}
        {filtered.length === 0 && (
          <Card padding={32} style={{ textAlign: 'center' }}>
            <div style={{ font: '500 14px/1.4 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
              검색 결과가 없습니다
            </div>
          </Card>
        )}
        <div style={{ height: 80 }} />
      </div>
    </div>
  );
};

const IngredientDetail = ({ state, setRoute, dispatch, id }) => {
  const ing = state.ingredients.find((i) => i.id === id);
  const toast = useToast();
  const [showDelete, setShowDelete] = useState(false);
  const [showEdit, setShowEdit] = useState(false);
  const [editPrice, setEditPrice] = useState(ing?.price ?? 0);
  const [editStock, setEditStock] = useState(ing?.stock ?? 0);

  if (!ing) return null;

  // Find dependencies
  const usedInSauces = state.sauces.filter((s) => s.items.some((it) => it.ingId === id));
  const usedInRecipes = state.recipes.filter((r) => r.ingredients.some((it) => it.ingId === id));
  const sauceIds = usedInSauces.map((s) => s.id);
  const recipesViaSauce = state.recipes.filter((r) => r.sauces.some((sr) => sauceIds.includes(sr.sauceId))
    && !usedInRecipes.find((x) => x.id === r.id));

  const history = SEED_PRICE_HISTORY[id] || [];
  const d = daysUntil(ing.expiry);

  const saveEdit = () => {
    dispatch({ type: 'UPDATE_INGREDIENT', id, patch: { price: parseFloat(editPrice), stock: parseFloat(editStock) } });
    setShowEdit(false);
    toast('수정했어요. 관련 레시피 원가가 재계산됩니다', 'positive');
  };
  const doDelete = () => {
    dispatch({ type: 'DELETE_INGREDIENT', id });
    setShowDelete(false);
    toast('재료를 삭제했어요. 30일 내 복구 가능', 'neutral');
    setRoute({ name: 'ingredients' });
  };

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title={ing.name} onBack={() => setRoute({ name: 'ingredients' })}
        trailing={<>
          <button onClick={() => setShowEdit(true)} style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-strong)' }}>
            <Icon name="edit" size={20} />
          </button>
          <button onClick={() => setShowDelete(true)} style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-strong)' }}>
            <Icon name="trash" size={20} />
          </button>
        </>}
      />

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* Hero */}
        <Card padding={20}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
            <div style={{
              width: 56, height: 56, borderRadius: 16,
              background: ing.category === '육류' ? '#FEECEC' : ing.category === '채소' ? '#F2FFF6' : ing.category === '조미료' ? '#FEF4E6' : 'var(--bg-muted)',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              font: '700 13px/1 var(--font-sans)',
              color: ing.category === '육류' ? '#B20C0C' : ing.category === '채소' ? '#006E25' : ing.category === '조미료' ? '#D47800' : 'var(--fg-secondary)',
            }}>{ing.category}</div>
            <div style={{ flex: 1 }}>
              <div style={{ font: '700 22px/1.3 var(--font-sans)', letterSpacing: '-0.02em' }}>{ing.name}</div>
              <div style={{ font: '500 13px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>{ing.category}</div>
            </div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 12 }}>
            <div>
              <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>단가</div>
              <div style={{ font: '700 17px/1.3 var(--font-sans)', marginTop: 2 }}>{fmtKRWdec(ing.price)}</div>
              <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>/{ing.unit}</div>
            </div>
            <div>
              <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>재고</div>
              <div style={{ font: '700 17px/1.3 var(--font-sans)', marginTop: 2 }}>{ing.stock.toLocaleString()}<span style={{ font: '500 12px/1 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{ing.unit}</span></div>
              <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRW(ing.price * ing.stock)}</div>
            </div>
            <div>
              <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>유통기한</div>
              <div style={{ font: '700 17px/1.3 var(--font-sans)', marginTop: 2, color: d <= 3 ? 'var(--negative)' : 'var(--fg-strong)' }}>D-{d}</div>
              <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{ing.expiry.replace(/-/g, '.')}</div>
            </div>
          </div>
        </Card>

        {/* Price history */}
        {history.length > 0 && (
          <Card padding={16}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 }}>
              <div>
                <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>단가 추이 (5개월)</div>
                <div style={{ font: '700 18px/1.3 var(--font-sans)', marginTop: 4 }}>
                  {fmtKRWdec(history[history.length - 1].p)}/{ing.unit}
                  <span style={{ font: '600 12px/1 var(--font-sans)', color: history[history.length - 1].p > history[0].p ? 'var(--negative)' : 'var(--positive)', marginLeft: 6 }}>
                    {history[history.length - 1].p > history[0].p ? '↑' : '↓'} {Math.abs(((history[history.length - 1].p - history[0].p) / history[0].p) * 100).toFixed(1)}%
                  </span>
                </div>
              </div>
              <Icon name="history" size={18} color="var(--fg-tertiary)" />
            </div>
            <Sparkline data={history.map((h) => h.p)} w={296} h={70} />
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4 }}>
              {history.map((h) => (
                <div key={h.d} style={{ font: '500 10px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
                  {h.d.split('-')[1]}월
                </div>
              ))}
            </div>
          </Card>
        )}

        {/* Used in */}
        {(usedInSauces.length > 0 || usedInRecipes.length > 0) && (
          <Card padding={0} style={{ overflow: 'hidden' }}>
            <div style={{ padding: '14px 16px', borderBottom: '1px solid var(--border-subtle)' }}>
              <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>사용 중인 곳</div>
              <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                소스 {usedInSauces.length}개 · 레시피 {usedInRecipes.length + recipesViaSauce.length}개
              </div>
            </div>
            {usedInSauces.map((s, i) => (
              <div key={s.id} style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border-subtle)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <Icon name="blend" size={18} color="var(--positive)" />
                  <div>
                    <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{s.name}</div>
                    <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                      이 재료 {s.items.find(it => it.ingId === id).qty}{ing.unit} 사용
                    </div>
                  </div>
                </div>
                <Icon name="chevronRight" size={16} color="var(--fg-tertiary)" />
              </div>
            ))}
            {[...usedInRecipes, ...recipesViaSauce].map((r, i, arr) => (
              <div key={r.id} onClick={() => setRoute({ name: 'recipe', id: r.id })}
                style={{ padding: '12px 16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: i < arr.length - 1 ? '1px solid var(--border-subtle)' : 'none', cursor: 'pointer' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <span style={{ fontSize: 18 }}>{r.image}</span>
                  <div>
                    <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{r.name}</div>
                    <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>레시피</div>
                  </div>
                </div>
                <Icon name="chevronRight" size={16} color="var(--fg-tertiary)" />
              </div>
            ))}
          </Card>
        )}
        <div style={{ height: 80 }} />
      </div>

      {/* Edit sheet */}
      <Sheet open={showEdit} onClose={() => setShowEdit(false)} title="재료 수정"
        actions={<>
          <Button variant="tertiary" full onClick={() => setShowEdit(false)}>취소</Button>
          <Button variant="primary" full onClick={saveEdit}>저장</Button>
        </>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <Field label="단가" hint="변경 시 가격 이력에 자동 적재">
            <Input value={editPrice} onChange={setEditPrice} type="number" suffix={`원/${ing.unit}`} />
          </Field>
          <Field label="재고" hint="실측한 수량을 입력하세요">
            <Input value={editStock} onChange={setEditStock} type="number" suffix={ing.unit} />
          </Field>
          <div style={{
            padding: '12px 14px', background: 'var(--info-soft)', borderRadius: 12,
            display: 'flex', alignItems: 'flex-start', gap: 8,
          }}>
            <Icon name="info" size={16} color="var(--info)" style={{ marginTop: 1 }} />
            <div style={{ font: '500 12px/1.45 var(--font-sans)', color: 'var(--fg-secondary)' }}>
              단가가 바뀌면 이 재료를 쓰는 <b>소스 {usedInSauces.length}개, 레시피 {usedInRecipes.length + recipesViaSauce.length}개</b>의 원가가 자동으로 다시 계산됩니다.
            </div>
          </div>
        </div>
      </Sheet>

      {/* Delete sheet */}
      <Sheet open={showDelete} onClose={() => setShowDelete(false)} title="이 재료를 삭제할까요?"
        actions={<>
          <Button variant="tertiary" full onClick={() => setShowDelete(false)}>취소</Button>
          <Button variant="danger" full onClick={doDelete}>삭제</Button>
        </>}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{
            padding: '14px', background: 'var(--negative-soft)', borderRadius: 12,
            display: 'flex', alignItems: 'flex-start', gap: 10,
          }}>
            <Icon name="alert" size={18} color="var(--negative)" style={{ marginTop: 1 }} />
            <div style={{ font: '500 13px/1.45 var(--font-sans)', color: 'var(--fg-strong)' }}>
              이 재료를 쓰는 항목도 함께 정리됩니다.
            </div>
          </div>
          {usedInSauces.length > 0 && (
            <div>
              <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em', marginBottom: 6 }}>영향받는 소스 {usedInSauces.length}개</div>
              {usedInSauces.map((s) => (
                <div key={s.id} style={{ padding: '10px 12px', background: 'var(--bg-muted)', borderRadius: 10, marginBottom: 4, font: '500 13px/1.3 var(--font-sans)' }}>
                  · {s.name}
                </div>
              ))}
            </div>
          )}
          {[...usedInRecipes, ...recipesViaSauce].length > 0 && (
            <div>
              <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em', marginBottom: 6 }}>영향받는 레시피 {usedInRecipes.length + recipesViaSauce.length}개</div>
              {[...usedInRecipes, ...recipesViaSauce].map((r) => (
                <div key={r.id} style={{ padding: '10px 12px', background: 'var(--bg-muted)', borderRadius: 10, marginBottom: 4, font: '500 13px/1.3 var(--font-sans)', display: 'flex', justifyContent: 'space-between' }}>
                  <span>· {r.name}</span>
                  <span style={{ color: 'var(--fg-tertiary)', font: '500 12px/1.3 var(--font-sans)' }}>연결만 제거</span>
                </div>
              ))}
            </div>
          )}
          <div style={{ font: '500 11px/1.5 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
            소프트 삭제로 처리되며 <b>30일 내 복구</b>할 수 있어요.
          </div>
        </div>
      </Sheet>
    </div>
  );
};

/* ──────────────────────────────────────────────────────────
   INGREDIENT NEW (form)
   ────────────────────────────────────────────────────────── */
const IngredientNew = ({ state, setRoute, dispatch }) => {
  const toast = useToast();
  const [name, setName] = useState('');
  const [unit, setUnit] = useState('g');
  const [price, setPrice] = useState('');
  const [stock, setStock] = useState('');
  const [expiry, setExpiry] = useState('');
  const [category, setCategory] = useState('채소');
  const [errors, setErrors] = useState({});

  const validate = () => {
    const e = {};
    if (!name.trim()) e.name = '재료명을 입력하세요';
    else if (state.ingredients.some((i) => i.name === name.trim() && !i.deleted)) e.name = '이미 등록된 재료명입니다';
    if (!price || parseFloat(price) <= 0) e.price = '0보다 큰 단가를 입력하세요';
    if (!stock || parseFloat(stock) < 0) e.stock = '재고 수량을 입력하세요';
    if (!expiry) e.expiry = '유통기한을 선택하세요';
    else if (new Date(expiry) < new Date('2026-05-04')) e.expiry = '오늘 이후 날짜를 선택하세요';
    return e;
  };

  const submit = () => {
    const e = validate();
    setErrors(e);
    if (Object.keys(e).length > 0) return;
    const id = 'i' + Date.now();
    dispatch({
      type: 'ADD_INGREDIENT',
      ingredient: {
        id, name: name.trim(), unit, price: parseFloat(price),
        stock: parseFloat(stock), expiry, category,
      },
    });
    toast(`'${name}' 등록 완료`, 'positive');
    setRoute({ name: 'ingredients' });
  };

  const units = ['g', 'kg', 'ml', 'l', '개'];
  const cats = ['육류', '채소', '조미료', '유제품', '곡물'];

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title="재료 등록" onBack={() => setRoute({ name: 'ingredients' })} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Card padding={16}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <Field label="재료명" error={errors.name}>
              <Input value={name} onChange={setName} placeholder="예: 돼지 삼겹살" error={!!errors.name} />
            </Field>
            <Field label="분류">
              <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                {cats.map((c) => (
                  <button key={c} onClick={() => setCategory(c)}
                    style={{
                      border: 0, padding: '7px 14px', borderRadius: 999, cursor: 'pointer',
                      font: '600 13px/1 var(--font-sans)',
                      background: category === c ? 'var(--fg-strong)' : 'rgba(112,115,124,0.08)',
                      color: category === c ? '#fff' : 'var(--fg-secondary)',
                    }}>{c}</button>
                ))}
              </div>
            </Field>
            <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', gap: 10 }}>
              <Field label="단가" error={errors.price}>
                <Input value={price} onChange={setPrice} placeholder="0" type="number" suffix={`원/${unit}`} error={!!errors.price} />
              </Field>
              <Field label="단위">
                <select value={unit} onChange={(e) => setUnit(e.target.value)}
                  style={{
                    border: 0, font: '500 15px/1.467 var(--font-sans)', padding: '11px 14px',
                    borderRadius: 12, boxShadow: 'inset 0 0 0 1px var(--border-subtle)',
                    background: '#fff', appearance: 'none', cursor: 'pointer',
                  }}>
                  {units.map((u) => <option key={u} value={u}>{u}</option>)}
                </select>
              </Field>
            </div>
            <Field label="현재 재고" error={errors.stock}>
              <Input value={stock} onChange={setStock} placeholder="0" type="number" suffix={unit} error={!!errors.stock} />
            </Field>
            <Field label="유통기한" error={errors.expiry}>
              <Input value={expiry} onChange={setExpiry} type="date" error={!!errors.expiry} />
            </Field>
          </div>
        </Card>
        <Button variant="primary" size="lg" full onClick={submit}>등록하기</Button>
        <div style={{ height: 40 }} />
      </div>
    </div>
  );
};

/* ──────────────────────────────────────────────────────────
   OCR — receipt scan flow
   ────────────────────────────────────────────────────────── */
const OcrScreen = ({ state, setRoute, dispatch }) => {
  const toast = useToast();
  const [step, setStep] = useState('scan'); // scan -> processing -> review
  const [items, setItems] = useState([]);

  // Mock OCR result
  const startScan = () => {
    setStep('processing');
    setTimeout(() => {
      setItems([
        { id: 'o1', name: '한우 등심', unit: 'g', price: 88, stock: 600, expiry: '2026-05-09', category: '육류', selected: true, status: 'ok' },
        { id: 'o2', name: '청양고추', unit: 'g', price: 22, stock: 500, expiry: '2026-05-08', category: '채소', selected: true, status: 'ok' },
        { id: 'o3', name: '대파', unit: 'g', price: 6.8, stock: 1000, expiry: '2026-05-12', category: '채소', selected: true, status: 'duplicate', reason: '이미 등록됨 — 재고만 추가' },
        { id: 'o4', name: '다진마늘', unit: 'g', price: 24, stock: 400, expiry: '2026-06-01', category: '조미료', selected: true, status: 'ok' },
        { id: 'o5', name: '???', unit: '?', price: 0, stock: 0, expiry: '', category: '기타', selected: false, status: 'error', reason: '단가 인식 실패' },
        { id: 'o6', name: '쌈장', unit: 'g', price: 12, stock: 500, expiry: '2026-09-01', category: '조미료', selected: true, status: 'ok' },
      ]);
      setStep('review');
    }, 1800);
  };

  const toggle = (id) => setItems((arr) => arr.map((x) => x.id === id ? { ...x, selected: !x.selected } : x));
  const okCount = items.filter((x) => x.selected && x.status !== 'error').length;
  const errCount = items.filter((x) => x.status === 'error').length;

  const save = () => {
    const ok = items.filter((x) => x.selected && x.status === 'ok');
    ok.forEach((it) => dispatch({
      type: 'ADD_INGREDIENT',
      ingredient: { ...it, id: 'i' + Date.now() + Math.random() },
    }));
    toast(`${ok.length}개 등록 완료`, 'positive');
    setRoute({ name: 'ingredients' });
  };

  if (step === 'scan') {
    return (
      <div style={{ background: '#000', minHeight: '100%', position: 'relative' }}>
        <div style={{ position: 'absolute', top: 60, left: 0, right: 0, padding: 16, zIndex: 10, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <button onClick={() => setRoute({ name: 'ingredients' })} style={{ border: 0, background: 'rgba(0,0,0,0.4)', padding: 8, borderRadius: 999, cursor: 'pointer', color: '#fff' }}>
            <Icon name="x" size={22} />
          </button>
          <div style={{ font: '600 14px/1.3 var(--font-sans)', color: '#fff', background: 'rgba(0,0,0,0.4)', padding: '6px 12px', borderRadius: 999 }}>
            영수증 스캔
          </div>
          <div style={{ width: 38 }} />
        </div>
        <div style={{
          position: 'absolute', inset: 0,
          background: 'linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 50%, #1a1a1a 100%)',
        }}>
          {/* Scan frame */}
          <div style={{
            position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -55%)',
            width: 240, height: 320, borderRadius: 16,
          }}>
            <div style={{
              position: 'absolute', inset: 0, border: '2px solid rgba(255,255,255,0.3)', borderRadius: 16,
            }} />
            {['top left', 'top right', 'bottom left', 'bottom right'].map((corner) => {
              const [v, h] = corner.split(' ');
              return (
                <div key={corner} style={{
                  position: 'absolute',
                  [v]: -2, [h]: -2,
                  width: 24, height: 24,
                  borderTop: v === 'top' ? '3px solid #fff' : 'none',
                  borderBottom: v === 'bottom' ? '3px solid #fff' : 'none',
                  borderLeft: h === 'left' ? '3px solid #fff' : 'none',
                  borderRight: h === 'right' ? '3px solid #fff' : 'none',
                  borderRadius: '4px',
                }} />
              );
            })}
            {/* Scan line */}
            <div style={{
              position: 'absolute', left: 8, right: 8, top: '40%',
              height: 2, background: 'linear-gradient(90deg, transparent, #0066FF, transparent)',
              boxShadow: '0 0 12px #0066FF',
              animation: 'scanLine 2s ease-in-out infinite',
            }} />
          </div>
          <div style={{
            position: 'absolute', bottom: 140, left: 0, right: 0,
            textAlign: 'center', font: '500 13px/1.4 var(--font-sans)', color: 'rgba(255,255,255,0.7)', padding: '0 32px',
          }}>
            영수증을 프레임 안에 맞춰주세요
          </div>
        </div>
        <div style={{
          position: 'absolute', bottom: 0, left: 0, right: 0,
          padding: '24px 24px calc(40px + env(safe-area-inset-bottom))',
          display: 'flex', justifyContent: 'center',
        }}>
          <button onClick={startScan} style={{
            width: 72, height: 72, borderRadius: 999,
            background: '#fff', border: '4px solid rgba(255,255,255,0.3)',
            cursor: 'pointer',
            boxShadow: '0 4px 16px rgba(0,0,0,0.4)',
          }} />
        </div>
      </div>
    );
  }

  if (step === 'processing') {
    return (
      <div style={{ background: '#fff', minHeight: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 24, padding: '60px 32px 32px' }}>
        <div style={{ position: 'relative', width: 80, height: 80 }}>
          <div style={{
            position: 'absolute', inset: 0, borderRadius: 999,
            border: '4px solid var(--primary-soft)', borderTopColor: 'var(--primary)',
            animation: 'spin 800ms linear infinite',
          }} />
          <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="sparkle" size={28} color="var(--accent-ai)" />
          </div>
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ font: '700 18px/1.3 var(--font-sans)', letterSpacing: '-0.012em' }}>영수증 분석 중</div>
          <div style={{ font: '500 13px/1.4 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 6 }}>
            재료명·수량·단가를 추출하고 있어요
          </div>
        </div>
      </div>
    );
  }

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title="OCR 결과 검토" onBack={() => setStep('scan')} />
      <div style={{ padding: '0 16px 16px' }}>
        <div style={{
          padding: '14px 16px', background: '#fff', borderRadius: 16,
          display: 'flex', alignItems: 'center', justifyContent: 'space-between',
          marginBottom: 12,
        }}>
          <div>
            <div style={{ font: '700 16px/1.3 var(--font-sans)', letterSpacing: '-0.01em' }}>{items.length}개 항목 인식</div>
            <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
              성공 {items.length - errCount} · 실패 {errCount}
            </div>
          </div>
          <Badge tone="ai" size="md">
            <Icon name="sparkle" size={11} /> AI
          </Badge>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
          {items.map((it) => {
            const tone = it.status === 'error' ? 'negative' : it.status === 'duplicate' ? 'warning' : 'positive';
            const toneLabel = { error: '실패', duplicate: '중복', ok: '신규' };
            return (
              <Card key={it.id} padding={14} style={{
                opacity: it.status === 'error' ? 0.6 : 1,
                boxShadow: it.selected ? 'inset 0 0 0 2px var(--primary)' : 'inset 0 0 0 1px var(--border-subtle)',
              }}>
                <div style={{ display: 'flex', gap: 12 }}>
                  <button onClick={() => it.status !== 'error' && toggle(it.id)}
                    disabled={it.status === 'error'}
                    style={{
                      width: 22, height: 22, borderRadius: 6, border: 0, padding: 0,
                      background: it.selected ? 'var(--primary)' : '#fff',
                      boxShadow: it.selected ? 'none' : 'inset 0 0 0 1.5px var(--border-default)',
                      cursor: it.status === 'error' ? 'not-allowed' : 'pointer',
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      flexShrink: 0,
                    }}>
                    {it.selected && <Icon name="check" size={14} color="#fff" strokeWidth={2.5} />}
                  </button>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                      <div style={{ font: '600 15px/1.3 var(--font-sans)', color: 'var(--fg-strong)' }}>{it.name}</div>
                      <Badge tone={tone} size="sm">{toneLabel[it.status]}</Badge>
                    </div>
                    {it.status !== 'error' ? (
                      <div style={{ font: '500 12px/1.4 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 4 }}>
                        {fmtKRWdec(it.price)}/{it.unit} · {it.stock}{it.unit}
                      </div>
                    ) : (
                      <div style={{ font: '500 12px/1.4 var(--font-sans)', color: 'var(--negative)', marginTop: 4 }}>
                        {it.reason}
                      </div>
                    )}
                    {it.status === 'duplicate' && (
                      <div style={{ font: '500 12px/1.4 var(--font-sans)', color: 'var(--warning)', marginTop: 4 }}>
                        {it.reason}
                      </div>
                    )}
                  </div>
                </div>
              </Card>
            );
          })}
        </div>
      </div>
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        padding: '12px 16px calc(16px + env(safe-area-inset-bottom))',
        background: '#fff', borderTop: '1px solid var(--border-subtle)',
        display: 'flex', gap: 8, zIndex: 5,
      }}>
        <Button variant="tertiary" onClick={() => setRoute({ name: 'ingredients' })}>취소</Button>
        <Button variant="primary" full onClick={save} disabled={okCount === 0}>
          {okCount}개 일괄 등록
        </Button>
      </div>
      <div style={{ height: 80 }} />
    </div>
  );
};

/* ──────────────────────────────────────────────────────────
   RECIPES LIST + DETAIL
   ────────────────────────────────────────────────────────── */
const RecipesScreen = ({ state, setRoute }) => {
  const recipes = state.recipes
    .map((r) => ({ ...r, cost: calcRecipeCost(r, state.ingredients, state.sauces) }))
    .map((r) => ({ ...r, marginPct: margin(r.sellPrice, r.cost) }));
  const sauces = state.sauces.map((s) => ({ ...s, cost: calcSauceCost(s, state.ingredients) }));
  const [tab, setTab] = useState('recipe');

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <div style={{ background: '#fff', position: 'sticky', top: 0, zIndex: 5 }}>
        <AppBar title="레시피" large
          subtitle={`레시피 ${recipes.length}개 · 소스 ${sauces.length}개`}
          trailing={<button onClick={() => setRoute({ name: tab === 'recipe' ? 'recipe-new' : 'sauce-new' })}
            style={{ border: 0, background: 'var(--primary)', color: '#fff', padding: '6px 12px', borderRadius: 999, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4, font: '600 13px/1 var(--font-sans)' }}>
            <Icon name="plus" size={16} /> {tab === 'recipe' ? '레시피' : '소스'}
          </button>}
        />
        <div style={{ padding: '0 16px 12px' }}>
          <Segment value={tab} onChange={setTab} options={[
            { value: 'recipe', label: `레시피 ${recipes.length}` },
            { value: 'sauce', label: `소스 ${sauces.length}` },
          ]} />
        </div>
      </div>

      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 8 }}>
        {tab === 'recipe' && recipes.map((r) => (
          <Card key={r.id} padding={16} onClick={() => setRoute({ name: 'recipe', id: r.id })}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 56, height: 56, borderRadius: 14, background: 'var(--bg-muted)',
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28,
                flexShrink: 0,
              }}>{r.image}</div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '700 16px/1.3 var(--font-sans)', letterSpacing: '-0.01em' }}>{r.name}</div>
                <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  재료 {r.ingredients.length}개 · 소스 {r.sauces.length}개 · {r.servings}인분
                </div>
                <div style={{ display: 'flex', gap: 10, marginTop: 8 }}>
                  <span style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
                    원가 <span style={{ color: 'var(--fg-strong)' }}>{fmtKRW(r.cost)}</span>
                  </span>
                  <span style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
                    판매 <span style={{ color: 'var(--fg-strong)' }}>{fmtKRW(r.sellPrice)}</span>
                  </span>
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ font: '700 20px/1 var(--font-sans)', letterSpacing: '-0.018em', color: r.marginPct >= 60 ? 'var(--positive)' : r.marginPct >= 40 ? 'var(--warning)' : 'var(--negative)' }}>
                  {r.marginPct.toFixed(0)}%
                </div>
                <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 4 }}>마진율</div>
              </div>
            </div>
          </Card>
        ))}
        {tab === 'sauce' && sauces.map((s) => (
          <Card key={s.id} padding={16}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <div style={{
                width: 44, height: 44, borderRadius: 12, background: 'rgba(0,191,64,0.1)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                color: 'var(--positive)',
              }}><Icon name="blend" size={22} /></div>
              <div style={{ flex: 1 }}>
                <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>{s.name}</div>
                <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  재료 {s.items.length}개
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>{fmtKRWdec(s.cost)}</div>
                <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>1배치</div>
              </div>
            </div>
          </Card>
        ))}
        <div style={{ height: 80 }} />
      </div>
    </div>
  );
};

const RecipeDetail = ({ state, setRoute, dispatch, id }) => {
  const recipe = state.recipes.find((r) => r.id === id);
  const [sellPrice, setSellPrice] = useState(recipe?.sellPrice ?? 0);
  if (!recipe) return null;

  const cost = calcRecipeCost(recipe, state.ingredients, state.sauces);
  const m = margin(sellPrice, cost);
  const profit = sellPrice - cost;

  // Composition
  const items = [
    ...recipe.ingredients.map((it) => {
      const ing = state.ingredients.find((i) => i.id === it.ingId);
      return ing ? { name: ing.name, qty: it.qty, unit: ing.unit, value: ing.price * it.qty, type: 'ing' } : null;
    }),
    ...recipe.sauces.map((it) => {
      const s = state.sauces.find((x) => x.id === it.sauceId);
      return s ? { name: s.name, qty: it.qty, unit: '배치', value: calcSauceCost(s, state.ingredients) * it.qty, type: 'sauce' } : null;
    }),
  ].filter(Boolean).sort((a, b) => b.value - a.value);

  const colors = ['#0066FF', '#6541F2', '#00BF40', '#FF9200', '#00BDDE', '#FA73E3', '#FF5E00'];

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title={recipe.name} onBack={() => setRoute({ name: 'recipes' })}
        trailing={<button style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-strong)' }}>
          <Icon name="moreH" size={22} />
        </button>}
      />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* Hero with margin */}
        <Card padding={20}>
          <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12 }}>
            <div style={{
              width: 64, height: 64, borderRadius: 16, background: 'var(--bg-muted)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 32,
            }}>{recipe.image}</div>
            <div style={{ flex: 1 }}>
              <div style={{ font: '700 22px/1.25 var(--font-sans)', letterSpacing: '-0.018em' }}>{recipe.name}</div>
              <div style={{ font: '500 13px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 4 }}>
                {recipe.servings}인분 · 구성 {items.length}개
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginTop: 20 }}>
            <Donut
              size={120} stroke={14}
              centerLabel="마진율"
              centerValue={`${m.toFixed(0)}%`}
              items={[
                { value: cost, color: 'var(--bg-muted)' },
                { value: profit > 0 ? profit : 0, color: m >= 60 ? 'var(--positive)' : m >= 40 ? 'var(--warning)' : 'var(--negative)' },
              ]}
            />
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>판매가</span>
                <span style={{ font: '700 14px/1.3 var(--font-sans)' }}>{fmtKRW(sellPrice)}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>총 원가</span>
                <span style={{ font: '700 14px/1.3 var(--font-sans)' }}>{fmtKRW(cost)}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', paddingTop: 6, borderTop: '1px solid var(--border-subtle)' }}>
                <span style={{ font: '600 13px/1.3 var(--font-sans)' }}>1인 이익</span>
                <span style={{ font: '700 16px/1.3 var(--font-sans)', color: 'var(--primary)' }}>{fmtKRW(profit)}</span>
              </div>
            </div>
          </div>

          {/* Sell price slider */}
          <div style={{ marginTop: 20, padding: '14px 14px 12px', background: 'var(--bg-muted)', borderRadius: 12 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 8 }}>
              <span style={{ font: '600 13px/1.3 var(--font-sans)' }}>판매가 시뮬레이션</span>
              <span style={{ font: '700 15px/1.3 var(--font-sans)', color: 'var(--primary)' }}>{fmtKRW(sellPrice)}</span>
            </div>
            <input type="range" min={Math.round(cost)} max={Math.round(cost * 4)} step={100}
              value={sellPrice} onChange={(e) => setSellPrice(parseInt(e.target.value))}
              style={{ width: '100%', accentColor: 'var(--primary)' }}
            />
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4, font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
              <span>{fmtKRW(cost)}</span>
              <span>{fmtKRW(cost * 4)}</span>
            </div>
          </div>
        </Card>

        {/* Composition */}
        <Card padding={0} style={{ overflow: 'hidden' }}>
          <div style={{ padding: '14px 16px', borderBottom: '1px solid var(--border-subtle)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>원가 구성</div>
              <div style={{ font: '600 13px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRW(cost)}</div>
            </div>
            <div style={{ marginTop: 12 }}>
              <BarStack items={items.map((it, i) => ({ value: it.value, color: colors[i % colors.length] }))} total={cost} height={10} />
            </div>
          </div>
          {items.map((it, i) => (
            <div key={i} style={{
              padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 10,
              borderBottom: i < items.length - 1 ? '1px solid var(--border-subtle)' : 'none',
            }}>
              <div style={{ width: 8, height: 8, borderRadius: 999, background: colors[i % colors.length] }} />
              <div style={{ flex: 1 }}>
                <div style={{ font: '600 14px/1.3 var(--font-sans)', display: 'flex', alignItems: 'center', gap: 6 }}>
                  {it.name}
                  {it.type === 'sauce' && <Badge tone="positive" size="sm">소스</Badge>}
                </div>
                <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  {it.qty}{it.unit}
                </div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ font: '700 14px/1.3 var(--font-sans)' }}>{fmtKRW(it.value)}</div>
                <div style={{ font: '500 11px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  {((it.value / cost) * 100).toFixed(1)}%
                </div>
              </div>
            </div>
          ))}
        </Card>
        <div style={{ height: 80 }} />
      </div>
    </div>
  );
};

/* ──────────────────────────────────────────────────────────
   REPORTS — full charts dashboard
   ────────────────────────────────────────────────────────── */
const ReportsScreen = ({ state, setRoute }) => {
  const { ingredients, sauces, recipes } = state;
  const [period, setPeriod] = useState('week');

  // Category breakdown
  const byCat = {};
  ingredients.forEach((i) => {
    if (i.deleted) return;
    byCat[i.category] = (byCat[i.category] || 0) + i.price * i.stock;
  });
  const catItems = Object.entries(byCat).map(([k, v]) => ({ label: k, value: v }))
    .sort((a, b) => b.value - a.value);
  const totalInv = catItems.reduce((s, x) => s + x.value, 0);

  // Recipes by margin
  const byMargin = recipes.map((r) => ({
    ...r,
    cost: calcRecipeCost(r, ingredients, sauces),
    marginPct: margin(r.sellPrice, calcRecipeCost(r, ingredients, sauces)),
  })).sort((a, b) => b.marginPct - a.marginPct);

  // Cost trend
  const trend = [
    { d: '12/9', v: 38.2 }, { d: '12/16', v: 39.1 }, { d: '12/23', v: 40.8 },
    { d: '12/30', v: 39.5 }, { d: '1/6', v: 41.2 }, { d: '1/13', v: 42.4 },
    { d: '1/20', v: 41.8 }, { d: '1/27', v: 40.5 }, { d: '오늘', v: 39.8 },
  ];

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title="리포트" large subtitle="원가·재고·마진 한눈에" />

      <div style={{ padding: '0 16px 16px' }}>
        <Segment value={period} onChange={setPeriod} options={[
          { value: 'week', label: '주간' },
          { value: 'month', label: '월간' },
          { value: 'quarter', label: '분기' },
        ]} />
      </div>

      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* Cost rate trend */}
        <Card padding={16}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', letterSpacing: '0.025em' }}>평균 원가율</div>
              <div style={{ font: '700 28px/1.2 var(--font-sans)', letterSpacing: '-0.022em', marginTop: 4 }}>
                {trend[trend.length - 1].v}<span style={{ font: '600 16px/1 var(--font-sans)', color: 'var(--fg-tertiary)' }}>%</span>
              </div>
              <div style={{ font: '600 12px/1.3 var(--font-sans)', color: 'var(--positive)', marginTop: 2, display: 'flex', alignItems: 'center', gap: 2 }}>
                <Icon name="arrowDown" size={12} /> 0.7%p 전주 대비
              </div>
            </div>
            <Badge tone="positive" size="sm">목표 40% 달성</Badge>
          </div>
          <div style={{ marginTop: 16, marginLeft: -4 }}>
            <Sparkline data={trend.map((t) => t.v)} w={300} h={80} />
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 4 }}>
            {trend.map((t, i) => (i % 2 === 0 || i === trend.length - 1) && (
              <div key={i} style={{ font: '500 10px/1.2 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{t.d}</div>
            ))}
          </div>
        </Card>

        {/* Inventory by category — Donut */}
        <Card padding={16}>
          <div style={{ font: '700 15px/1.3 var(--font-sans)', marginBottom: 4 }}>재고 가치 구성</div>
          <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>분류별 재고 평가액</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 16, marginTop: 16 }}>
            <Donut size={140} stroke={20} items={catItems}
              centerLabel="총 재고" centerValue={fmtKRW(totalInv).replace('₩', '₩')} />
            <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 8 }}>
              {catItems.map((c, i) => {
                const colors = ['#0066FF', '#6541F2', '#00BF40', '#FF9200', '#00BDDE', '#FA73E3'];
                return (
                  <div key={c.label} style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                    <div style={{ width: 8, height: 8, borderRadius: 2, background: colors[i % colors.length] }} />
                    <div style={{ flex: 1, font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-secondary)' }}>{c.label}</div>
                    <div style={{ font: '700 12px/1.3 var(--font-sans)' }}>{((c.value / totalInv) * 100).toFixed(0)}%</div>
                  </div>
                );
              })}
            </div>
          </div>
        </Card>

        {/* Margin ranking */}
        <Card padding={0} style={{ overflow: 'hidden' }}>
          <div style={{ padding: '14px 16px', borderBottom: '1px solid var(--border-subtle)', display: 'flex', justifyContent: 'space-between' }}>
            <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>마진율 순위</div>
            <button onClick={() => setRoute({ name: 'recipes' })}
              style={{ border: 0, background: 'transparent', font: '600 12px/1 var(--font-sans)', color: 'var(--primary)', cursor: 'pointer' }}>
              전체보기
            </button>
          </div>
          {byMargin.map((r, i) => (
            <div key={r.id} onClick={() => setRoute({ name: 'recipe', id: r.id })}
              style={{
                padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer',
                borderBottom: i < byMargin.length - 1 ? '1px solid var(--border-subtle)' : 'none',
              }}>
              <div style={{
                width: 24, height: 24, borderRadius: 999,
                background: i === 0 ? 'var(--primary)' : 'var(--bg-muted)',
                color: i === 0 ? '#fff' : 'var(--fg-secondary)',
                font: '700 12px/1 var(--font-sans)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>{i + 1}</div>
              <span style={{ fontSize: 22 }}>{r.image}</span>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{r.name}</div>
                <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                  {fmtKRW(r.cost)} → {fmtKRW(r.sellPrice)}
                </div>
              </div>
              <div style={{
                font: '700 16px/1 var(--font-sans)', letterSpacing: '-0.012em',
                color: r.marginPct >= 60 ? 'var(--positive)' : r.marginPct >= 40 ? 'var(--warning)' : 'var(--negative)',
              }}>{r.marginPct.toFixed(0)}%</div>
            </div>
          ))}
        </Card>

        {/* Top expensive ingredients */}
        <Card padding={16}>
          <div style={{ font: '700 15px/1.3 var(--font-sans)', marginBottom: 4 }}>비싼 재료 TOP 5</div>
          <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>단가 기준</div>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10, marginTop: 16 }}>
            {[...ingredients].sort((a, b) => b.price - a.price).slice(0, 5).map((ing, i) => {
              const max = ingredients.reduce((m, x) => Math.max(m, x.price), 0);
              return (
                <div key={ing.id}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                    <span style={{ font: '600 13px/1.3 var(--font-sans)' }}>{ing.name}</span>
                    <span style={{ font: '700 13px/1.3 var(--font-sans)' }}>{fmtKRWdec(ing.price)}/{ing.unit}</span>
                  </div>
                  <div style={{ height: 6, background: 'var(--bg-muted)', borderRadius: 999, overflow: 'hidden' }}>
                    <div style={{
                      width: `${(ing.price / max) * 100}%`, height: '100%',
                      background: i === 0 ? 'var(--primary)' : 'var(--primary-soft)',
                      borderRadius: 999,
                    }} />
                  </div>
                </div>
              );
            })}
          </div>
        </Card>

        <div style={{ height: 100 }} />
      </div>
    </div>
  );
};

/* ──────────────────────────────────────────────────────────
   SAUCE NEW + RECIPE NEW (lighter forms)
   ────────────────────────────────────────────────────────── */
const SauceNew = ({ state, setRoute, dispatch }) => {
  const toast = useToast();
  const [name, setName] = useState('');
  const [items, setItems] = useState([]);
  const [showPick, setShowPick] = useState(false);

  const cost = useMemo(() => items.reduce((s, it) => {
    const ing = state.ingredients.find((i) => i.id === it.ingId);
    return s + (ing ? ing.price * it.qty : 0);
  }, 0), [items, state.ingredients]);

  const addItem = (ing) => {
    if (items.find((it) => it.ingId === ing.id)) return;
    setItems((arr) => [...arr, { ingId: ing.id, qty: 10 }]);
    setShowPick(false);
  };
  const updateQty = (ingId, qty) => {
    setItems((arr) => arr.map((it) => it.ingId === ingId ? { ...it, qty: parseFloat(qty) || 0 } : it));
  };
  const removeItem = (ingId) => setItems((arr) => arr.filter((it) => it.ingId !== ingId));

  const submit = () => {
    if (!name.trim()) { toast('소스 이름을 입력해주세요', 'negative'); return; }
    if (items.length === 0) { toast('재료를 1개 이상 추가해주세요', 'negative'); return; }
    dispatch({
      type: 'ADD_SAUCE',
      sauce: { id: 's' + Date.now(), name: name.trim(), items },
    });
    toast(`'${name}' 소스 등록 완료`, 'positive');
    setRoute({ name: 'recipes' });
  };

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title="소스 만들기" onBack={() => setRoute({ name: 'recipes' })} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Card padding={16}>
          <Field label="소스 이름">
            <Input value={name} onChange={setName} placeholder="예: 제육 양념" />
          </Field>
        </Card>

        <Card padding={0} style={{ overflow: 'hidden' }}>
          <div style={{ padding: '14px 16px', borderBottom: items.length > 0 ? '1px solid var(--border-subtle)' : 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>구성 재료</div>
              <div style={{ font: '500 12px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)', marginTop: 2 }}>
                {items.length}개 · 원가 {fmtKRWdec(cost)}
              </div>
            </div>
            <Button variant="secondary" size="sm" icon="plus" onClick={() => setShowPick(true)}>재료 추가</Button>
          </div>
          {items.map((it, i) => {
            const ing = state.ingredients.find((x) => x.id === it.ingId);
            if (!ing) return null;
            return (
              <div key={it.ingId} style={{
                padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 10,
                borderBottom: i < items.length - 1 ? '1px solid var(--border-subtle)' : 'none',
              }}>
                <div style={{ flex: 1 }}>
                  <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{ing.name}</div>
                  <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRWdec(ing.price)}/{ing.unit}</div>
                </div>
                <div style={{ width: 100 }}>
                  <Input value={it.qty} onChange={(v) => updateQty(it.ingId, v)} type="number" suffix={ing.unit} />
                </div>
                <button onClick={() => removeItem(it.ingId)} style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-tertiary)' }}>
                  <Icon name="x" size={18} />
                </button>
              </div>
            );
          })}
          {items.length === 0 && (
            <div style={{ padding: 28, textAlign: 'center', font: '500 13px/1.4 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
              재료를 1개 이상 추가하세요
            </div>
          )}
        </Card>

        {items.length > 0 && (
          <Card padding={16} style={{ background: 'var(--primary-soft)', boxShadow: 'none' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ font: '600 13px/1.3 var(--font-sans)', color: 'var(--primary)' }}>1배치 원가</div>
              <div style={{ font: '700 22px/1 var(--font-sans)', letterSpacing: '-0.018em', color: 'var(--primary)' }}>{fmtKRWdec(cost)}</div>
            </div>
          </Card>
        )}

        <Button variant="primary" size="lg" full onClick={submit}>등록하기</Button>
        <div style={{ height: 80 }} />
      </div>

      <Sheet open={showPick} onClose={() => setShowPick(false)} title="재료 선택">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {state.ingredients.filter((i) => !i.deleted && !items.find((it) => it.ingId === i.id)).map((ing) => (
            <div key={ing.id} onClick={() => addItem(ing)}
              style={{
                padding: '12px 14px', borderRadius: 12, cursor: 'pointer',
                background: 'var(--bg-muted)', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              }}>
              <div>
                <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{ing.name}</div>
                <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRWdec(ing.price)}/{ing.unit}</div>
              </div>
              <Icon name="plus" size={18} color="var(--primary)" />
            </div>
          ))}
        </div>
      </Sheet>
    </div>
  );
};

const RecipeNew = ({ state, setRoute, dispatch }) => {
  const toast = useToast();
  const [name, setName] = useState('');
  const [sellPrice, setSellPrice] = useState('');
  const [ingItems, setIngItems] = useState([]);
  const [sauceItems, setSauceItems] = useState([]);
  const [pick, setPick] = useState(null); // 'ing' | 'sauce' | null

  const cost = useMemo(() => {
    const ic = ingItems.reduce((s, it) => {
      const ing = state.ingredients.find((i) => i.id === it.ingId);
      return s + (ing ? ing.price * it.qty : 0);
    }, 0);
    const sc = sauceItems.reduce((s, it) => {
      const sa = state.sauces.find((x) => x.id === it.sauceId);
      return s + (sa ? calcSauceCost(sa, state.ingredients) * it.qty : 0);
    }, 0);
    return ic + sc;
  }, [ingItems, sauceItems, state]);

  const m = sellPrice ? margin(parseFloat(sellPrice), cost) : 0;

  const submit = () => {
    if (!name.trim()) { toast('레시피 이름을 입력해주세요', 'negative'); return; }
    if (ingItems.length === 0 && sauceItems.length === 0) { toast('재료 또는 소스를 추가해주세요', 'negative'); return; }
    dispatch({
      type: 'ADD_RECIPE',
      recipe: {
        id: 'r' + Date.now(), name: name.trim(), servings: 1,
        sellPrice: parseFloat(sellPrice) || 0, image: '🍽️',
        ingredients: ingItems, sauces: sauceItems,
      },
    });
    toast(`'${name}' 레시피 등록 완료`, 'positive');
    setRoute({ name: 'recipes' });
  };

  return (
    <div style={{ background: 'var(--bg-elev-2)', minHeight: '100%' }}>
      <AppBar title="레시피 등록" onBack={() => setRoute({ name: 'recipes' })} />
      <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Card padding={16}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <Field label="레시피 이름">
              <Input value={name} onChange={setName} placeholder="예: 제육볶음" />
            </Field>
            <Field label="판매가">
              <Input value={sellPrice} onChange={setSellPrice} type="number" placeholder="0" suffix="원" />
            </Field>
          </div>
        </Card>

        {/* Ingredients */}
        <Card padding={0} style={{ overflow: 'hidden' }}>
          <div style={{ padding: '14px 16px', borderBottom: ingItems.length > 0 ? '1px solid var(--border-subtle)' : 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>재료 {ingItems.length > 0 && <span style={{ color: 'var(--fg-tertiary)', fontWeight: 500, fontSize: 13 }}>{ingItems.length}</span>}</div>
            <Button variant="secondary" size="sm" icon="plus" onClick={() => setPick('ing')}>추가</Button>
          </div>
          {ingItems.map((it, i) => {
            const ing = state.ingredients.find((x) => x.id === it.ingId);
            if (!ing) return null;
            return (
              <div key={it.ingId} style={{
                padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 10,
                borderBottom: i < ingItems.length - 1 ? '1px solid var(--border-subtle)' : 'none',
              }}>
                <div style={{ flex: 1 }}>
                  <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{ing.name}</div>
                  <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRW(ing.price * it.qty)}</div>
                </div>
                <div style={{ width: 90 }}>
                  <Input value={it.qty} onChange={(v) => setIngItems((arr) => arr.map((x) => x.ingId === it.ingId ? { ...x, qty: parseFloat(v) || 0 } : x))} type="number" suffix={ing.unit} />
                </div>
                <button onClick={() => setIngItems((arr) => arr.filter((x) => x.ingId !== it.ingId))} style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-tertiary)' }}>
                  <Icon name="x" size={18} />
                </button>
              </div>
            );
          })}
        </Card>

        {/* Sauces */}
        <Card padding={0} style={{ overflow: 'hidden' }}>
          <div style={{ padding: '14px 16px', borderBottom: sauceItems.length > 0 ? '1px solid var(--border-subtle)' : 'none', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ font: '700 15px/1.3 var(--font-sans)' }}>소스 {sauceItems.length > 0 && <span style={{ color: 'var(--fg-tertiary)', fontWeight: 500, fontSize: 13 }}>{sauceItems.length}</span>}</div>
            <Button variant="secondary" size="sm" icon="plus" onClick={() => setPick('sauce')}>추가</Button>
          </div>
          {sauceItems.map((it, i) => {
            const sa = state.sauces.find((x) => x.id === it.sauceId);
            if (!sa) return null;
            const sc = calcSauceCost(sa, state.ingredients) * it.qty;
            return (
              <div key={it.sauceId} style={{
                padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 10,
                borderBottom: i < sauceItems.length - 1 ? '1px solid var(--border-subtle)' : 'none',
              }}>
                <Icon name="blend" size={18} color="var(--positive)" />
                <div style={{ flex: 1 }}>
                  <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{sa.name}</div>
                  <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRWdec(sc)}</div>
                </div>
                <div style={{ width: 80 }}>
                  <Input value={it.qty} onChange={(v) => setSauceItems((arr) => arr.map((x) => x.sauceId === it.sauceId ? { ...x, qty: parseFloat(v) || 0 } : x))} type="number" suffix="배치" />
                </div>
                <button onClick={() => setSauceItems((arr) => arr.filter((x) => x.sauceId !== it.sauceId))} style={{ border: 0, background: 'transparent', padding: 6, cursor: 'pointer', color: 'var(--fg-tertiary)' }}>
                  <Icon name="x" size={18} />
                </button>
              </div>
            );
          })}
        </Card>

        {/* Cost preview */}
        {(ingItems.length > 0 || sauceItems.length > 0) && (
          <Card padding={16} style={{ background: 'var(--primary-soft)', boxShadow: 'none' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ font: '600 13px/1.3 var(--font-sans)', color: 'var(--primary)' }}>총 원가</span>
              <span style={{ font: '700 18px/1 var(--font-sans)', color: 'var(--primary)' }}>{fmtKRW(cost)}</span>
            </div>
            {sellPrice && (
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ font: '600 13px/1.3 var(--font-sans)', color: 'var(--primary)' }}>예상 마진율</span>
                <span style={{ font: '700 18px/1 var(--font-sans)', color: m >= 60 ? 'var(--positive)' : m >= 40 ? 'var(--warning)' : 'var(--negative)' }}>
                  {m.toFixed(1)}%
                </span>
              </div>
            )}
          </Card>
        )}

        <Button variant="primary" size="lg" full onClick={submit}>등록하기</Button>
        <div style={{ height: 80 }} />
      </div>

      <Sheet open={pick === 'ing'} onClose={() => setPick(null)} title="재료 선택">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {state.ingredients.filter((i) => !i.deleted && !ingItems.find((it) => it.ingId === i.id)).map((ing) => (
            <div key={ing.id} onClick={() => { setIngItems((arr) => [...arr, { ingId: ing.id, qty: 100 }]); setPick(null); }}
              style={{
                padding: '12px 14px', borderRadius: 12, cursor: 'pointer',
                background: 'var(--bg-muted)', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              }}>
              <div>
                <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{ing.name}</div>
                <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>{fmtKRWdec(ing.price)}/{ing.unit}</div>
              </div>
              <Icon name="plus" size={18} color="var(--primary)" />
            </div>
          ))}
        </div>
      </Sheet>

      <Sheet open={pick === 'sauce'} onClose={() => setPick(null)} title="소스 선택">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          {state.sauces.filter((s) => !sauceItems.find((it) => it.sauceId === s.id)).map((s) => (
            <div key={s.id} onClick={() => { setSauceItems((arr) => [...arr, { sauceId: s.id, qty: 1 }]); setPick(null); }}
              style={{
                padding: '12px 14px', borderRadius: 12, cursor: 'pointer',
                background: 'var(--bg-muted)', display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                <Icon name="blend" size={18} color="var(--positive)" />
                <div>
                  <div style={{ font: '600 14px/1.3 var(--font-sans)' }}>{s.name}</div>
                  <div style={{ font: '500 11px/1.3 var(--font-sans)', color: 'var(--fg-tertiary)' }}>
                    {fmtKRWdec(calcSauceCost(s, state.ingredients))}/배치
                  </div>
                </div>
              </div>
              <Icon name="plus" size={18} color="var(--primary)" />
            </div>
          ))}
        </div>
      </Sheet>
    </div>
  );
};

Object.assign(window, {
  HomeScreen, IngredientsScreen, IngredientDetail, IngredientNew,
  OcrScreen, RecipesScreen, RecipeDetail, ReportsScreen, SauceNew, RecipeNew,
});
