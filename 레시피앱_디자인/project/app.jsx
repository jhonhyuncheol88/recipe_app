/* global React, ReactDOM, IOSDevice, ToastProvider, TabBar,
   HomeScreen, IngredientsScreen, IngredientDetail, IngredientNew,
   OcrScreen, RecipesScreen, RecipeDetail, ReportsScreen, SauceNew, RecipeNew,
   SEED_INGREDIENTS, SEED_SAUCES, SEED_RECIPES,
   TweaksPanel, useTweaks, TweakSection, TweakRadio, TweakToggle, TweakColor */
const { useState, useEffect, useReducer } = React;

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "primaryColor": "#0066FF",
  "showWelcome": true,
  "marginGoal": 60,
  "density": "comfortable"
}/*EDITMODE-END*/;

// State reducer
const initialState = {
  ingredients: SEED_INGREDIENTS,
  sauces: SEED_SAUCES,
  recipes: SEED_RECIPES,
};

const reducer = (state, action) => {
  switch (action.type) {
    case 'ADD_INGREDIENT':
      return { ...state, ingredients: [action.ingredient, ...state.ingredients] };
    case 'UPDATE_INGREDIENT':
      return {
        ...state,
        ingredients: state.ingredients.map((i) =>
          i.id === action.id ? { ...i, ...action.patch } : i),
      };
    case 'DELETE_INGREDIENT':
      return {
        ...state,
        ingredients: state.ingredients.map((i) =>
          i.id === action.id ? { ...i, deleted: true } : i),
        sauces: state.sauces.map((s) => ({
          ...s,
          items: s.items.filter((it) => it.ingId !== action.id),
        })),
        recipes: state.recipes.map((r) => ({
          ...r,
          ingredients: r.ingredients.filter((it) => it.ingId !== action.id),
        })),
      };
    case 'ADD_SAUCE':
      return { ...state, sauces: [action.sauce, ...state.sauces] };
    case 'ADD_RECIPE':
      return { ...state, recipes: [action.recipe, ...state.recipes] };
    default:
      return state;
  }
};

const App = () => {
  const [state, dispatch] = useReducer(reducer, initialState);
  const [route, setRoute] = useState({ name: 'home' });
  const [tweaks, setTweak] = useTweaks(TWEAK_DEFAULTS);

  // Apply primary color tweak
  useEffect(() => {
    document.documentElement.style.setProperty('--primary', tweaks.primaryColor);
    // Derive hover/press
    const c = tweaks.primaryColor;
    document.documentElement.style.setProperty('--primary-hover', c);
    document.documentElement.style.setProperty('--primary-press', c);
  }, [tweaks.primaryColor]);

  // Bottom tab routing
  const bottomActive = ['home', 'ingredients', 'recipes', 'reports'].includes(route.name)
    ? route.name : null;

  // Hide tab bar on detail/form screens
  const hideTabBar = ['ingredient', 'ingredient-new', 'ocr', 'recipe', 'sauce-new', 'recipe-new'].includes(route.name);

  let screen = null;
  switch (route.name) {
    case 'home': screen = <HomeScreen state={state} setRoute={setRoute} />; break;
    case 'ingredients': screen = <IngredientsScreen state={state} setRoute={setRoute} dispatch={dispatch} />; break;
    case 'ingredient': screen = <IngredientDetail state={state} setRoute={setRoute} dispatch={dispatch} id={route.id} />; break;
    case 'ingredient-new': screen = <IngredientNew state={state} setRoute={setRoute} dispatch={dispatch} />; break;
    case 'ocr': screen = <OcrScreen state={state} setRoute={setRoute} dispatch={dispatch} />; break;
    case 'recipes': screen = <RecipesScreen state={state} setRoute={setRoute} />; break;
    case 'recipe': screen = <RecipeDetail state={state} setRoute={setRoute} dispatch={dispatch} id={route.id} />; break;
    case 'sauce-new': screen = <SauceNew state={state} setRoute={setRoute} dispatch={dispatch} />; break;
    case 'recipe-new': screen = <RecipeNew state={state} setRoute={setRoute} dispatch={dispatch} />; break;
    case 'reports': screen = <ReportsScreen state={state} setRoute={setRoute} />; break;
    default: screen = <HomeScreen state={state} setRoute={setRoute} />;
  }

  return (
    <>
      <ToastProvider>
        <div style={{
          width: '100%', height: '100%', position: 'relative',
          background: 'var(--bg-elev-2)', overflow: 'hidden',
          display: 'flex', flexDirection: 'column',
        }}>
          <div style={{ flex: 1, overflowY: 'auto', overflowX: 'hidden', WebkitOverflowScrolling: 'touch' }}>
            {screen}
          </div>
          {!hideTabBar && bottomActive && (
            <TabBar active={bottomActive} onChange={(t) => setRoute({ name: t })} />
          )}
        </div>
      </ToastProvider>

      <TweaksPanel title="Tweaks" defaultPosition={{ right: 20, bottom: 20 }}>
        <TweakSection title="브랜드">
          <TweakColor label="Primary" value={tweaks.primaryColor}
            onChange={(v) => setTweak('primaryColor', v)}
            presets={['#0066FF', '#6541F2', '#00BF40', '#FF5E00', '#171719']}
          />
        </TweakSection>
        <TweakSection title="네비게이션">
          <TweakRadio label="현재 화면" value={route.name === 'home' ? 'home' : route.name === 'ingredients' ? 'ingredients' : route.name === 'recipes' ? 'recipes' : 'reports'}
            options={[
              { value: 'home', label: '홈' },
              { value: 'ingredients', label: '재료' },
              { value: 'recipes', label: '레시피' },
              { value: 'reports', label: '리포트' },
            ]}
            onChange={(v) => setRoute({ name: v })}
          />
        </TweakSection>
        <TweakSection title="플로우 데모">
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 6 }}>
            {[
              { name: 'ocr', label: 'OCR 스캔' },
              { name: 'ingredient-new', label: '재료 등록' },
              { name: 'sauce-new', label: '소스 만들기' },
              { name: 'recipe-new', label: '레시피 등록' },
              { name: 'ingredient', id: 'i1', label: '재료 상세' },
              { name: 'recipe', id: 'r1', label: '레시피 상세' },
            ].map((it) => (
              <button key={it.label} onClick={() => setRoute(it)}
                style={{
                  border: 0, padding: '8px 10px', borderRadius: 8,
                  background: 'rgba(112,115,124,0.1)', color: 'var(--fg-strong)',
                  font: '600 11px/1.2 var(--font-sans)', cursor: 'pointer',
                }}>{it.label}</button>
            ))}
          </div>
        </TweakSection>
      </TweaksPanel>
    </>
  );
};

// Mount inside iOS device frame
const Mount = () => (
  <div style={{
    minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
    background: 'linear-gradient(180deg, #EAEBEC 0%, #DBDCDF 100%)',
    padding: 24,
  }}>
    <IOSDevice width={402} height={874}>
      <App />
    </IOSDevice>
  </div>
);

ReactDOM.createRoot(document.getElementById('root')).render(<Mount />);
