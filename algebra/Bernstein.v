Require Export CPolynomials.
Require Import CSums.
Require Import Rational.

Set Implicit Arguments.

Require Import CRing_Homomorphisms.

(*
Section PolynomialRingHomomorphism.
Variable F R:CRing.
Variable eta : RingHom F R.

Definition poly_rhmap := compose_CSetoid_fun _ _ _ eta _C_.

Lemma poly_rh1 : fun_pres_plus _ _ poly_rhmap.
Proof.
intros x y.
simpl; split; auto with *.
Qed.

Lemma poly_rh2 : fun_pres_mult _ _ poly_rhmap.
Proof.
intros x y.
simpl; split; auto.
rstepr (eta x[*]eta y).
auto with *.
Qed.

Lemma poly_rh3 : fun_pres_unit _ _ poly_rhmap.
Proof.
split; simpl; auto with *.
Qed.

Definition CPoly_RingHom : RingHom _ _ := Build_RingHom _ _ _ poly_rh1 poly_rh2 poly_rh3.
Canonical Structure CPoly_RingHom.

End PolynomialRingHomomorphism.
*)
(*
Require Import CModules.

Section PolynomialModule.

Variable F R:CRing.
Variable mu : CSetoid_bin_fun F R R.
Hypothesis Hmodule : is_RModule R mu.

Let RM := Build_RModule _ _ _ Hmodule.

Fixpoint cpoly_mu_cr (a:F) (x:cpoly_cring R) : cpoly_cring R :=
match x with 
| cpoly_zero => cpoly_zero R
| cpoly_linear d q1 => cpoly_linear R (mu a d) (cpoly_mu_cr a q1)
end.

Lemma cpoly_mu_cr_strext : bin_fun_strext _ _ _ cpoly_mu_cr.
Proof.
intros a b x.
induction x; intros y.
 induction y.
  intros; contradiction.
 intros H.
 simpl in H.
 destruct H as [H|H].
  right.
  left.
  apply (mu_axap0_xap0 _ RM b s H).
 simpl in IHy.
 simpl.
 tauto.
destruct y; simpl.
 intros [H|H].
  right; left.
  apply (mu_axap0_xap0 _ RM a s H).
 destruct (IHx Zero); try tauto.
  apply ap_symmetric; apply H.
 right; right.
 change (Zero[#]x).
 apply ap_symmetric; auto with *.
intros [H|H].
 destruct (csbf_strext _ _ _ _ _ _ _ _ H); tauto.
destruct (IHx _ H); tauto.
Defined.

Lemma cpoly_mu_cr_wd : bin_fun_wd _ _ _ cpoly_mu_cr.
Proof.
apply bin_fun_strext_imp_wd.
exact cpoly_mu_cr_strext.
Qed.

Definition cpoly_mu : CSetoid_bin_fun F (cpoly_cring R) (cpoly_cring R) :=
 Build_CSetoid_bin_fun _ _ _ _ cpoly_mu_cr_strext.

Lemma cpoly_mu_distr_plus  : 
 forall (a : F) (x y : cpoly_cring R),
 cpoly_mu a (x[+]y)[=]cpoly_mu a x[+]cpoly_mu a y.
Proof.
induction x; destruct y.
   simpl; auto.
  split; reflexivity.
 split; reflexivity.
split.
 apply rm_pl1; auto.
apply IHx.
Qed.

Lemma plus_distr_cpoly_mu : 
 forall (a b : F) (x : cpoly_cring R),
 cpoly_mu (a[+]b) x[=]cpoly_mu a x[+]cpoly_mu b x.
Proof.
induction x.
 reflexivity.
split; auto.
apply rm_pl2; auto.
Qed.

Lemma cpoly_mu_assoc : 
forall (a b : F) (x : cpoly_cring R),
cpoly_mu (a[*]b) x[=]cpoly_mu a (cpoly_mu b x).
Proof.
induction x.
 reflexivity.
split; auto.
apply rm_mult; auto.
Qed.

Lemma cpoly_mu_one : 
 forall x : cpoly_cring R, cpoly_mu One x[=]x.
induction x.
 reflexivity.
split; auto.
apply rm_one; auto.
Qed.

Lemma CPolyModule : is_RModule (cpoly_cring R) cpoly_mu.
Proof.
split.
   apply cpoly_mu_distr_plus.
  apply plus_distr_cpoly_mu.
 apply cpoly_mu_assoc.
apply cpoly_mu_one.
Qed.

Canonical Structure CPoly_as_Module := Build_RModule _ _ _ CPolyModule.

( * This ought to belong to a general theory about alegbras * )
Lemma CPoly_mu_mult_assoc : 
forall (a : F) (x y: cpoly_cring R),
(forall (b c:R), mu a (b[*]c)[=]mu a b[*]c) ->
cpoly_mu a (x[*]y)[=](cpoly_mu a x)[*]y.
Proof.
intros a x y H.
change (a['](x[*]y)[=](a[']x)[*]y).
revert y.
induction x; intros y.
 rewrite mu_azero.
 setoid_replace (Zero[*]y) with (Zero:cpoly_cring R);[|rational].
 auto with *.
simpl (a['](cpoly_linear R s x:CPoly_as_Module)).
rewrite (poly_linear _ (mu a s)).
rewrite (mult_commut_unfolded (cpoly_cring R) _X_).
rewrite ring_distl_unfolded.
rewrite <- mult_assoc_unfolded.
rewrite <- IHx.
rewrite mult_assoc_unfolded.
change (_C_ (mu a s)) with (a['](_C_ s)).
setoid_replace (a[']_C_ s[*]y) with (a['](_C_ s[*]y)).
 rewrite <- (mu_plus1 F CPoly_as_Module).
 rewrite poly_linear.
 apply csbf_wd; [reflexivity|].
 change ((_X_[*]x[+]_C_ s)[*]y[=]x[*]_X_[*]y[+]_C_ s[*]y).
 rational.
clear - H.
simpl (_C_ s[*]y).
simpl (a[']_C_ s[*]y).
do 2 rewrite cpoly_mult_fast_equiv.
setoid_replace (cpoly_mult_cs R (cpoly_constant R s) y) with
 (cpoly_mult_cr R y s).
 induction y.
  simpl; split; auto with *.
 split; simpl.
  rstepl (mu a s[*]s0).
  symmetry.
  apply H.
 change (cpoly_mult_cr R y (mu a s)[+]Zero[=](@rm_mu F CPoly_as_Module) a (cpoly_mult_cr R y s)).
 setoid_replace (Zero:cpoly_cring R) with (cpoly_linear R Zero Zero).
  apply IHy.
 split;simpl; auto with *.
change (((cpoly_mult_cr R y s)[+](cpoly_linear R Zero Zero):cpoly_cring R)[=]cpoly_mult_cr R y s).
change (((cpoly_mult_cr R y s)[+](cpoly_linear R Zero Zero):cpoly_cring R)[=]cpoly_mult_cr R y s).
setoid_replace (cpoly_linear R Zero Zero:cpoly_cring R) with (Zero:cpoly_cring R).
 rational.
split; simpl; auto with *.
Qed.

End PolynomialModule.
*)
Require Import Qordfield.
Close Scope Q_scope.

Section Bernstein.

Opaque cpoly_cring.
Opaque _C_.

Variable R : CRing.

Fixpoint Bernstein (n i:nat) {struct n}: (i <= n) -> cpoly_cring R :=
match n return (i <= n) -> cpoly_cring R  with
 O => fun _ => One
|S n' => 
  match i return (i <= S n') -> cpoly_cring R  with
   O => fun _ => (One[-]_X_)[*](Bernstein (le_O_n n'))
  |S i' => fun p =>
    match (le_lt_eq_dec _ _ p) with
     | left p' => (One[-]_X_)[*](Bernstein (lt_n_Sm_le _ _ p'))[+]_X_[*](Bernstein (le_S_n _ _ p))
     | right _ => _X_[*](Bernstein (lt_n_Sm_le _ _ p))
    end
  end
end.

Lemma Bernstein_inv1 : forall n i (H:i < n) (H0:S i <= S n),
 Bernstein H0[=](One[-]_X_)[*](Bernstein (lt_n_Sm_le _ _ (lt_n_S _ _ H)))[+]_X_[*](Bernstein (le_S_n _ _ H0)).
Proof.
intros n i H H0.
simpl (Bernstein H0).
destruct (le_lt_eq_dec _ _ H0).
 replace (lt_n_Sm_le (S i) n l) with (lt_n_Sm_le _ _ (lt_n_S _ _ H)) by apply le_irrelevent.
 reflexivity.
elimtype False; omega.
Qed. 

Lemma Bernstein_inv2 : forall n (H:S n <= S n),
 Bernstein H[=]_X_[*](Bernstein (le_S_n _ _ H)).
Proof.
intros n H.
simpl (Bernstein H).
destruct (le_lt_eq_dec _ _ H).
 elimtype False; omega.
replace (lt_n_Sm_le n n H) with (le_S_n n n H) by apply le_irrelevent.
reflexivity.
Qed. 

(*
Lemma Bernstein_ind : forall n i (H:i<=n) (P : nat -> nat -> cpoly_cring R -> Prop),
P 0 0 One ->
(forall n p, P n 0 p -> P (S n) 0 ((One[-]_X_)[*]p)) ->
(forall n p, P n n p -> P (S n) (S n) (_X_[*]p)) ->
(forall i n p q, (i < n) -> P n i p -> P n (S i) q -> P (S n) (S i) ((One[-]_X_)[*]q[+]_X_[*]p)) ->
P n i (Bernstein H).
Proof.
intros n i H P H0 H1 H2 H3.
revert n i H.
induction n;
  intros [|i] H.
   apply H0.
  elimtype False; auto with *.
 apply H1.
 apply IHn.
simpl.
destruct (le_lt_eq_dec (S i) (S n)).
 apply H3; auto with *.
inversion e.
revert H.
rewrite H5.
intros H.
apply H2.
auto with *.
Qed.
*)
Lemma partitionOfUnity : forall n, @Sumx (cpoly_cring R) _ (fun i H => Bernstein (lt_n_Sm_le i n H)) [=]One.
Proof.
induction n.
 reflexivity.
set (A:=(fun (i : nat) (H : i < S n) => Bernstein (lt_n_Sm_le i n H))) in *.
set (B:=(fun i => (One[-]_X_)[*](part_tot_nat_fun (cpoly_cring R) _ A i)[+]_X_[*]match i with O => Zero | S i' => (part_tot_nat_fun _ _ A i') end)).
rewrite (fun a b => Sumx_Sum0 _ a b B).
 unfold B.
 rewrite Sum0_plus_Sum0.
 do 2 rewrite mult_distr_sum0_lft.
 rewrite Sumx_to_Sum in IHn; auto with *.
  setoid_replace (Sum0 (S (S n)) (part_tot_nat_fun (cpoly_cring R) (S n) A))
   with (Sum0 (S (S n)) (part_tot_nat_fun (cpoly_cring R) (S n) A)[-]Zero);[|rational].
  change (Sum0 (S (S n)) (part_tot_nat_fun (cpoly_cring R) (S n) A)[-]Zero)
   with (Sum 0 (S n) (part_tot_nat_fun (cpoly_cring R) (S n) A)).
  set (C:=(fun i : nat =>
   match i with
   | 0 => (Zero : cpoly_cring R)
   | S i' => part_tot_nat_fun (cpoly_cring R) (S n) A i'
   end)).
  setoid_replace (Sum0 (S (S n)) C)
   with (Sum0 (S (S n)) C[-]Zero);[|rational].
  change (Sum0 (S (S n)) C[-]Zero) with (Sum 0 (S n) C).
  rewrite Sum_last.
  rewrite IHn.
  replace (part_tot_nat_fun (cpoly_cring R) (S n) A (S n)) with (Zero:cpoly_cring R).
   rewrite Sum_first.
   change (C 0) with (Zero:cpoly_cring R).
   rewrite <- (Sum_shift _ (part_tot_nat_fun (cpoly_cring R) (S n) A)).
    rewrite IHn.
    rational.
   reflexivity.
  unfold part_tot_nat_fun.
  destruct (le_lt_dec (S n) (S n)).
   reflexivity.
  elimtype False; omega.
 intros i j Hij.
 rewrite Hij.
 intros Hi Hj.
 unfold A.
 replace (lt_n_Sm_le j n Hi) with (lt_n_Sm_le j n Hj) by apply le_irrelevent.
 apply eq_reflexive.
destruct i;
 intros Hi;
 unfold B, A, part_tot_nat_fun.
 simpl (sumbool_rect (fun _ : {S n <= 0} + {0 < S n} => cpoly_cring R)
   (fun _ : S n <= 0 => Zero)
   (fun b : 0 < S n => Bernstein (lt_n_Sm_le 0 n b)) (le_lt_dec (S n) 0)).
 generalize (lt_n_Sm_le 0 (S n) Hi) (lt_n_Sm_le 0 n (gt_le_S 0 (S n) (lt_O_Sn n))).
 intros l l0.
 simpl (Bernstein l).
 replace l0 with (le_O_n n) by apply le_irrelevent.
 rational.
destruct (le_lt_dec (S n) i).
 elimtype False; omega.
destruct (le_lt_dec (S n) (S i));
 simpl (Bernstein (lt_n_Sm_le (S i) (S n) Hi));
 destruct (le_lt_eq_dec (S i) (S n) (lt_n_Sm_le (S i) (S n) Hi)).
   elimtype False; omega.
  replace  (lt_n_Sm_le i n (lt_n_Sm_le (S i) (S n) Hi))
  with (lt_n_Sm_le i n l) by apply le_irrelevent.
  simpl.
  rational.
 replace (le_S_n i n (lt_n_Sm_le (S i) (S n) Hi))
 with (lt_n_Sm_le i n l) by apply le_irrelevent.
 replace l1 with l0 by apply le_irrelevent.
 reflexivity.
elimtype False; omega.
Qed.

Lemma RaiseDegreeA : forall n i (H:i<=n), (nring (S n))[*]_X_[*]Bernstein H[=](nring (S i))[*]Bernstein (le_n_S _ _ H).
Proof.
induction n.
 intros [|i] H; [|elimtype False; omega].
 repeat split; rational.
intros i H.
change (nring (S (S n)):cpoly_cring R) with (nring (S n)[+]One:cpoly_cring R).
rstepl (nring (S n)[*]_X_[*]Bernstein H[+]_X_[*]Bernstein H).
destruct i as [|i].
 simpl (Bernstein H) at 1.
 rstepl ((One[-]_X_)[*](nring (S n)[*]_X_[*]Bernstein (le_O_n n))[+]
         _X_[*]Bernstein H).
 rewrite IHn.
 rstepl ((nring 1)[*]((One[-]_X_)[*]Bernstein (le_n_S _ _ (le_O_n n))[+]_X_[*]Bernstein H)).
 set (l0:=(lt_n_Sm_le _ _ (le_n_S 1 (S n) (gt_le_S 0 (S n) (gt_Sn_O n))))).
 replace (le_n_S 0 n (le_O_n n)) with l0 by apply le_irrelevent.
 reflexivity.
simpl (Bernstein H) at 1.
destruct (le_lt_eq_dec _ _ H).
 rstepl ((One[-]_X_)[*](nring (S n)[*]_X_[*]Bernstein (lt_n_Sm_le (S i) n l))[+]
         _X_[*](nring (S n)[*]_X_[*]Bernstein (le_S_n i n H))[+]
         _X_[*]Bernstein H).
 do 2 rewrite IHn.
 change (nring (S (S i)):cpoly_cring R) with (nring (S i)[+]One:cpoly_cring R).
 set (l0:= (le_n_S (S i) n (lt_n_Sm_le (S i) n l))).
 replace (le_n_S i n (le_S_n i n H)) with H by apply le_irrelevent.
 rstepl ((nring (S i)[+]One)[*]((One[-]_X_)[*]Bernstein l0[+]_X_[*]Bernstein H)).
 rewrite (Bernstein_inv1 l).
 replace (lt_n_Sm_le (S (S i)) (S n) (lt_n_S (S i) (S n) l))
  with l0 by apply le_irrelevent.
 replace (le_S_n (S i) (S n) (le_n_S (S i) (S n) H))
  with H by apply le_irrelevent.
 reflexivity.
rstepl (_X_[*](nring (S n)[*]_X_[*]Bernstein (lt_n_Sm_le _ _ H))[+]
        _X_[*]Bernstein H).
rewrite IHn.
replace (le_n_S i n (lt_n_Sm_le i n H)) with H by apply le_irrelevent.
revert H.
inversion_clear e.
intros H.
rewrite (Bernstein_inv2 (le_n_S _ _ H)).
replace (le_S_n (S n) (S n) (le_n_S (S n) (S n) H)) with H by apply le_irrelevent.
change (nring (S (S n)):cpoly_cring R) with (nring (S n)[+]One:cpoly_cring R).
rational.
Qed.

Lemma RaiseDegreeB : forall n i (H:i<=n), (nring (S n))[*](One[-]_X_)[*]Bernstein H[=](nring (S n - i))[*]Bernstein (le_S _ _ H).
Proof.
induction n.
 intros [|i] H; [|elimtype False; omega].
 repeat split; rational.
intros i H.
change (nring (S (S n)):cpoly_cring R) with (nring (S n)[+]One:cpoly_cring R).
set (X0:=(One[-]@_X_ R)) in *.
rstepl (nring (S n)[*]X0[*]Bernstein H[+]X0[*]Bernstein H).
destruct i as [|i].
 simpl (Bernstein H) at 1.
 fold X0.
 rstepl (X0[*](nring (S n)[*]X0[*]Bernstein (le_O_n n))[+]
         X0[*]Bernstein H).
 rewrite IHn.
 replace (le_S 0 n (le_O_n n)) with H by apply le_irrelevent.
 simpl (S n - 0).
 change (nring (S (S n) - 0):cpoly_cring R) with (nring (S n)[+]One:cpoly_cring R).
 rstepl ((nring (S n))[*](X0[*]Bernstein H)[+]X0[*]Bernstein H).
 change (Bernstein (le_S _ _ H)) with (X0[*]Bernstein (le_O_n (S n))).
 replace (le_O_n (S n)) with H by apply le_irrelevent.
 rational.
simpl (Bernstein H) at 1.
destruct (le_lt_eq_dec _ _ H).
 fold X0.
 rstepl (X0[*](nring (S n)[*]X0[*]Bernstein (lt_n_Sm_le (S i) n l))[+]
         _X_[*](nring (S n)[*]X0[*]Bernstein (le_S_n i n H))[+]
         X0[*]Bernstein H).
 do 2 rewrite IHn.
 rewrite <- (minus_Sn_m n i) by auto with *.
 rewrite <-(minus_Sn_m (S n) (S i)) by auto with *.
 replace (S n - S i) with (n - i) by auto with *.
 change (nring (S (n - i)):cpoly_cring R) with (nring (n - i)[+]One:cpoly_cring R).
 replace (le_S (S i) n (lt_n_Sm_le (S i) n l)) with H by apply le_irrelevent.
 set (l0:= (le_S i n (le_S_n i n H))).
 rstepl ((nring (n - i)[+]One)[*](X0[*]Bernstein H[+]_X_[*]Bernstein l0)). 
 rewrite (Bernstein_inv1 H).
 fold X0.
 replace (lt_n_Sm_le _ _ (lt_n_S _ _ H))
  with H by apply le_irrelevent.
 replace (le_S_n _ _ (le_S (S i) (S n) H))
  with l0 by apply le_irrelevent.
 reflexivity.
revert H.
inversion e.
clear - IHn.
intros H.
assert (l:(n < (S n))) by auto.
rewrite (Bernstein_inv1 l).
fold X0.
rstepl (_X_[*](nring (S n)[*]X0[*]Bernstein (lt_n_Sm_le _ _ H))[+]
        X0[*]Bernstein H).
rewrite IHn.
replace (S n - n) with 1 by auto with *.
replace (S (S n) - S n) with 1 by auto with *.
replace (le_S_n n (S n) (le_S (S n) (S n) H))
 with (le_S n n (lt_n_Sm_le n n H)) by apply le_irrelevent.
replace (lt_n_Sm_le (S n) (S n) (lt_n_S n (S n) l)) with H by apply le_irrelevent.
rational.
Qed.

Lemma RaiseDegree : forall n i (H: i<=n),
 (nring (S n))[*]Bernstein H[=](nring (S n - i))[*]Bernstein (le_S _ _ H)[+](nring (S i))[*]Bernstein (le_n_S _ _ H).
Proof.
intros n i H.
stepl ((nring (S n))[*](One[-]_X_)[*]Bernstein H[+](nring (S n))[*]_X_[*]Bernstein H) by rational.
rewrite RaiseDegreeA, RaiseDegreeB.
reflexivity.
Qed.

Opaque Bernstein.

Require Export Bvector.

Fixpoint evalBernsteinBasisH (n i:nat) (v:vector R i) : i <= n -> cpoly_cring R :=
match v in vector _ i return i <= n -> cpoly_cring R with
|Vnil => fun _ => Zero
|Vcons a i' v' => 
  match n as n return (S i' <= n) -> cpoly_cring R with
  | O => fun p => False_rect _ (le_Sn_O _ p)
  | S n' => fun p => _C_ a[*]Bernstein (le_S_n _ _ p)[+]evalBernsteinBasisH v' (le_Sn_le _ _ p)
  end
end.

Definition evalBernsteinBasis (n:nat) (v:vector R n) : cpoly_cring R :=
evalBernsteinBasisH v (le_refl n).

Lemma evalBernsteinBasisPlus : forall n (v1 v2: vector R n),
evalBernsteinBasis (Vbinary _ (fun (x y:R)=>x[+]y) _ v1 v2)[=]evalBernsteinBasis v1[+]evalBernsteinBasis v2.
Proof.
unfold evalBernsteinBasis.
intros n.
generalize (le_refl n).
generalize n at 1 3 4  6 7  9 11.
intros i.
induction i.
 intros l v1 v2.
 rewrite (V0_eq R v1), (V0_eq R v2).
 simpl.
 rational.
intros l v1 v2.
destruct n as [|n].
 elimtype False; auto with *.
rewrite (VSn_eq R _ v1), (VSn_eq R _ v2).
simpl.
rewrite IHi.
rewrite _c_plus.
unfold cpoly_constant.
rational.
Qed.

Lemma evalBernsteinBasisConst : forall n c,
evalBernsteinBasis (Vconst R c (S n))[=]_C_ c.
Proof.
intros n c.
stepr (evalBernsteinBasis (Vconst R c (S n))[+]_C_ c[*]Sum (S n) n (part_tot_nat_fun _ _ (fun (i : nat) (H : i < S n) => Bernstein (lt_n_Sm_le i n H)))).
 rewrite Sum_empty; auto with *.
 rational.
unfold evalBernsteinBasis.
generalize (le_refl (S n)).
generalize (S n) at 1 4 5 6.
intros i l.
induction i.
 rstepr (_C_ c[*]One).
 rewrite <- (partitionOfUnity n).
 rewrite Sumx_to_Sum; auto with *.
 intros i j Hij.
 rewrite Hij.
 intros H H'.
 replace (lt_n_Sm_le j n H) with (lt_n_Sm_le j n H') by apply le_irrelevent.
 reflexivity.
simpl.
rstepl (evalBernsteinBasisH (Vconst R c i) (le_Sn_le i (S n) l)[+]
_C_ c[*](Bernstein (le_S_n i n l)[+]
Sum (S i) n
  (part_tot_nat_fun (cpoly_cring R) (S n)
     (fun (i0 : nat) (H : i0 < S n) => Bernstein (lt_n_Sm_le i0 n H))))).
replace (Bernstein (le_S_n _ _ l)) with (part_tot_nat_fun (cpoly_cring R) (S n)
      (fun (i0 : nat) (H : i0 < S n) => Bernstein (lt_n_Sm_le i0 n H)) i).
 rewrite <- Sum_first.
 apply IHi.
clear - i.
unfold part_tot_nat_fun.
destruct (le_lt_dec (S n) i).
 elimtype False; auto with *.
simpl.
replace (lt_n_Sm_le _ _ l0) with (le_S_n _ _ l) by apply le_irrelevent.
reflexivity.
Qed.

Variable eta : RingHom Q_as_CRing R.

Opaque Qred.
Opaque Q_as_CRing.
Opaque Vbinary.
Opaque Vconst.

Fixpoint BernsteinBasisTimesXH (n i:nat) (v:vector R i) : i <= n -> vector R (S i) :=
match v in vector _ i return i <= n -> vector R (S i) with
| Vnil => fun _ => Vcons _ Zero _ (Vnil _)
| Vcons a i' v' => match n as n return S i' <= n -> vector R (S (S i')) with
  | O => fun p => False_rect _ (le_Sn_O _ p)
  | S n' => fun p => Vcons _ (eta(Qred (i#P_of_succ_nat n'))[*]a) _ (BernsteinBasisTimesXH v' (le_Sn_le _ _ p))
  end
end.

Definition BernsteinBasisTimesX (n:nat) (v:vector R n) : vector R (S n) :=
BernsteinBasisTimesXH v (le_refl n).

(****************************************************)
(*MOVE ME*)
Lemma Q_nring : forall n, (nring n:Q)[=]n.
induction n.
 reflexivity.
rewrite inj_S.
change ((nring (S n):Q)==((n+1)%Z:Q))%Q.
rewrite injz_plus.
simpl.
rewrite IHn.
reflexivity.
Qed.

(****************************************************)

Lemma evalBernsteinBasisTimesX : forall n (v:vector R n),
 evalBernsteinBasis (BernsteinBasisTimesX v)[=]_X_[*]evalBernsteinBasis v.
Proof.
intros n.
unfold evalBernsteinBasis, BernsteinBasisTimesX.
generalize (le_refl (S n)) (le_refl n).
generalize n at 1 3 5 7 9 11.
intros i.
induction i.
 intros l l0 v.
 rewrite (V0_eq R v).
 simpl.
 rewrite <- _c_zero.
 rational.
intros l l0 v.
destruct n as [|n].
 elimtype False; auto with *.
rewrite (VSn_eq R _ v).
simpl.
rewrite IHi.
rewrite _c_mult.
rewrite ring_dist_unfolded.
apply csbf_wd; try reflexivity.
set (A:= (_C_ (eta (Qred
                 (Qmake (Zpos (P_of_succ_nat i)) (P_of_succ_nat n)))))).
rstepl (_C_ (Vhead R i v)[*](A[*]Bernstein (le_S_n (S i) (S n) l))).
rstepr (_C_ (Vhead R i v)[*](_X_[*]Bernstein (le_S_n i n l0))).
apply mult_wdr.
unfold A; clear A.
assert (Hn : (nring (S n):Q)[#]Zero).
 stepl (S n:Q).
  simpl.
  unfold Qap, Qeq.
  auto with *.
 symmetry; apply Q_nring.
setoid_replace (Qred (P_of_succ_nat i # P_of_succ_nat n))
 with ((One[/](nring (S n))[//]Hn)[*](nring (S i))).
 set (eta':=RHcompose _ _ _ _C_ eta).
 change (_C_ (eta ((One[/]nring (S n)[//]Hn)[*]nring (S i))))
  with ((eta' ((One[/]nring (S n)[//]Hn)[*]nring (S i))):cpoly_cring R).
 rewrite rh_pres_mult.
 rewrite rh_pres_nring.
 rewrite <- mult_assoc_unfolded.
 replace (le_S_n (S i) (S n) l) with (le_n_S _ _ (le_S_n i n l0)) by apply le_irrelevent.
 rewrite <- RaiseDegreeA.
 rewrite <- (@rh_pres_nring _ _ eta').
 rewrite <- mult_assoc_unfolded.
 rewrite mult_assoc_unfolded.
 rewrite <- rh_pres_mult.
 setoid_replace (eta' ((One[/]nring (S n)[//]Hn)[*]nring (S n))) with (One:cpoly_cring R).
  rational.
 rewrite <- (@rh_pres_unit _ _ eta').
 apply csf_wd.
 apply (@div_1 Q_as_CField).
rewrite Qred_correct.
rewrite Qmake_Qdiv.
change (Zpos (P_of_succ_nat n)) with ((S n):Z).
rewrite <- (Q_nring (S n)).
change (Zpos (P_of_succ_nat i)) with ((S i):Z).
rewrite <- (Q_nring (S i)).
change (nring (S i)/nring (S n) == (1/(nring (S n)))*nring (S i))%Q.
field.
apply Hn.
Qed.

Fixpoint BernsteinCoefficents (p:cpoly_cring R) : sigT (vector R) :=
match p with
| cpoly_zero => existT _ _ (Vnil R)
| cpoly_linear c p' => 
  let (n', b') := (BernsteinCoefficents p') in
  existT _ _  (Vbinary _ (fun (x y:R)=>x[+]y) _ (Vconst R c _) (BernsteinBasisTimesX b'))
end.

Lemma evalBernsteinCoefficents : forall p, (let (n,b) := BernsteinCoefficents p in evalBernsteinBasis b)[=]p.
Proof.
induction p.
 reflexivity.
simpl.
destruct (BernsteinCoefficents p).
rewrite evalBernsteinBasisPlus.
rewrite evalBernsteinBasisConst.
rewrite evalBernsteinBasisTimesX.
rewrite IHp.
rewrite poly_linear.
rational.
Qed.

End Bernstein.

Require Import COrdFields2.

Section BernsteinOrdField.

Variable F : COrdField.

Opaque cpoly_cring.

Hint Resolve pos_one less_leEq shift_leEq_lft mult_resp_nonneg plus_resp_nonneg: inequality.

Lemma BernsteinNonNeg : forall x:F, Zero [<=] x -> x [<=] One ->
forall n i (p:le i n), Zero[<=](Bernstein F p)!x.
Proof.
intros x Hx0 Hx1.
induction n.
 intros i p.
 simpl (Bernstein F p).
 autorewrite with apply.
 auto with *.
intros [|i] p;
 simpl (Bernstein F p).
 autorewrite with apply.
 auto with *.
destruct (le_lt_eq_dec (S i) (S n) p);
 autorewrite with apply;
 auto with *.
Qed.

End BernsteinOrdField.