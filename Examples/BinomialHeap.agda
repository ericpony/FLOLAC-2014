open import Relation.Nullary using (Dec; yes; no)

module Examples.BinomialHeap (Val : Set) (_≤_ : Val → Val → Set) (_≤?_ : (x y : Val) → Dec (x ≤ y)) where

open import Prelude.Function
open import Prelude.InverseImage
open import Refinement
open import Description
open import Ornament
open import Ornament.RefinementSemantics

open import Data.Unit using (⊤; tt)
open import Data.Product using (Σ; _,_; _×_)
open import Data.Nat using (ℕ; zero; suc)
open import Data.List using (List; []; _∷_)
open import Relation.Binary.PropositionalEquality using (_≡_)


data BinTag : Set where
  `nil  : BinTag
  `zero : BinTag
  `one  : BinTag

BinD : Desc ⊤
BinD = wrap λ _ → σ BinTag λ { `nil  → ṿ []
                             ; `zero → ṿ (tt ∷ [])
                             ; `one  → ṿ (tt ∷ []) }

Bin : Set
Bin = μ BinD tt

incr : Bin → Bin
incr (con (`nil  , _    )) = con (`one , con (`nil , tt) , tt)
incr (con (`zero , b , _)) = con (`one , b , tt)
incr (con (`one  , b , _)) = con (`zero , incr b , tt)

descend : ℕ → List ℕ
descend zero    = []
descend (suc n) = n ∷ descend n

BTreeD : Desc ℕ
BTreeD = wrap λ r → σ[ _ ∶ Val ] ṿ (descend r)

BTree : ℕ → Set
BTree = μ BTreeD

link : {r : ℕ} → BTree r → BTree r → BTree (suc r)
link (con (x , ts)) (con (y , us)) with x ≤? y
link (con (x , ts)) (con (y , us)) | yes _ = con (x , con (y , us) , ts)
link (con (x , ts)) (con (y , us)) | no  _ = con (y , con (x , ts) , us)

BHeapOD : OrnDesc ℕ ! BinD
BHeapOD = wrap λ { {._} (ok r) → σ BinTag λ { `nil  → ṿ tt
                                            ; `zero → ṿ (ok (suc r) , tt)
                                            ; `one  → Δ[ _ ∶ BTree r ] ṿ (ok (suc r) , tt) } }

BHeap : ℕ → Set
BHeap = μ ⌊ BHeapOD ⌋

BHeap' : ℕ → Bin → Set
BHeap' r b = OptP ⌈ BHeapOD ⌉ (ok r) b

incr-insT : Upgrade (Bin → Bin) ({r : ℕ} → BTree r → BHeap r → BHeap r)
incr-insT = ∀⁺[[ r ∶ ℕ ]] ∀⁺[ _ ∶ BTree r ] let ref = FRefinement.comp (RSem' ⌈ BHeapOD ⌉) (ok r) in ref ⇀ toUpgrade ref

insT' : {r : ℕ} → BTree r → (b : Bin) → BHeap' r b → BHeap' r (incr b)  -- Upgrade.P incr-insT incr
insT' t (con (`nil  , _    )) h'                 = con (t , con tt , tt)
insT' t (con (`zero , b , _)) (con (    h' , _)) = con (t , h' , tt)
insT' t (con (`one  , b , _)) (con (u , h' , _)) = con (insT' (link t u) b h' , tt)

insT : {r : ℕ} → BTree r → BHeap r → BHeap r
insT = Upgrade.u incr-insT incr insT'

coherence-proof : {r : ℕ} (t : BTree r) (b : Bin) (h : BHeap r) →
                  forget ⌈ BHeapOD ⌉ h ≡ b → forget ⌈ BHeapOD ⌉ (insT t h) ≡ incr b  -- Upgrade.C incr-insT incr insT
coherence-proof = Upgrade.c incr-insT incr insT'

insert : Val → BHeap 0 → BHeap 0
insert x = insT (con (x , tt))
