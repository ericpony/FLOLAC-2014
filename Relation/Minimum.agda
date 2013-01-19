module Thesis.Relation.Minimum where

open import Thesis.Relation

open import Data.Product using (Σ; _,_; proj₁; proj₂; _×_)
import Relation.Binary.PreorderReasoning as PreorderReasoning

min_•Λ_ : {I : Set} {X Y : I → Set} → (R : Y ↝ Y) (S : X ↝ Y) → X ↝ Y
min R •Λ S = wrap λ x y → Λ S x y × (∀ y' → Λ S x y' → Λ R y' y)

min-universal-⇒ : {I : Set} {X Y : I → Set} {T : X ↝ Y} {R : Y ↝ Y} {S : X ↝ Y} → T ⊆ min R •Λ S → (T ⊆ S) × (T • S º ⊆ R)
min-universal-⇒ (wrap T⊆minR•ΛS) =
  wrap (λ x → wrap λ y t → proj₁ (_⊑_.comp (T⊆minR•ΛS x) y t)) ,
  wrap (λ y' → wrap λ { y (x , s , t) → proj₂ (_⊑_.comp (T⊆minR•ΛS x) y t) y' s })

min-universal-⇐ : {I : Set} {X Y : I → Set} {T : X ↝ Y} {R : Y ↝ Y} {S : X ↝ Y} → T ⊆ S → T • S º ⊆ R → T ⊆ min R •Λ S
min-universal-⇐ (wrap T⊆S) (wrap T•Sº⊆R) = wrap λ x → wrap λ y t → _⊑_.comp (T⊆S x) y t , (λ y' s → _⊑_.comp (T•Sº⊆R y') y (x , s , t))

min-monotonic : {I : Set} {X Y : I → Set} {R R' : Y ↝ Y} {S S' : X ↝ Y} → R ⊆ R' → S ≃ S' → min R •Λ S ⊆ min R' •Λ S'
min-monotonic {I} {X} {Y} {R} {R'} {S} {S'} R⊆R' (S⊆S' , S⊇S') =
  min-universal-⇐
    (⊆-trans (proj₁ (min-universal-⇒ ⊆-refl)) S⊆S')
    (begin
       min R •Λ S • S' º
         ⊆⟨ •-monotonic-l (min R •Λ S) (º-monotonic S⊇S') ⟩
       min R •Λ S • S º
         ⊆⟨ proj₂ (min-universal-⇒ ⊆-refl) ⟩
       R
         ⊆⟨ R⊆R' ⟩
       R'
     □)
  where open PreorderReasoning (⊆-Preorder Y Y) renaming (_∼⟨_⟩_ to _⊆⟨_⟩_; _∎ to _□)

min-cong : {I : Set} {X Y : I → Set} {R R' : Y ↝ Y} {S S' : X ↝ Y} → R ≃ R' → S ≃ S' → min R •Λ S ≃ min R' •Λ S'
min-cong (R⊆R' , R⊇R') (S⊆S' , S⊇S') = min-monotonic R⊆R' (S⊆S' , S⊇S') , min-monotonic R⊇R' (S⊇S' , S⊆S')