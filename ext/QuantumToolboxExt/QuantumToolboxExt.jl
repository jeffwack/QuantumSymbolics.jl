module QuantumToolboxExt

using QuantumToolbox
using QuantumSymbolics
using QuantumSymbolics:
    HGate, XGate, YGate, ZGate, CPHASEGate, CNOTGate, PauliP, PauliM,
    XCXGate, XCYGate, XCZGate, YCXGate, YCYGate, YCZGate, ZCXGate, ZCYGate, ZCZGate,
    XBasisState, YBasisState, ZBasisState,
    NumberOp, CreateOp, DestroyOp,
    FockState,
    MixedState, IdentityOp, STensor,
    qubit_basis
import QuantumSymbolics: express, express_nolookup
using TermInterface
using TermInterface: isexpr, head, operation, arguments, metadata

const _l0 = QuantumToolbox.basis(2,0)
const _l1 = QuantumToolbox.basis(2,1)
const _s₊ = (_l0+_l1)/√2
const _s₋ = (_l0-_l1)/√2
const _i₊ = (_l0+im*_l1)/√2
const _i₋ = (_l0-im*_l1)/√2
const _σ₊ = QuantumToolbox.sigmap()
const _σ₋ = QuantumToolbox.sigmam()
const _l00 = QuantumToolbox.proj(_l0)
const _l11 = QuantumToolbox.proj(_l1)
const _id = QuantumToolbox.qeye(2)
const _z = QuantumToolbox.sigmaz()
const _x = QuantumToolbox.sigmax()
const _y = QuantumToolbox.sigmay()
const _hadamard = (_z+_x)/√2
const _cnot = QuantumToolbox.tensor(_l00,_id) + QuantumToolbox.tensor(_l11,_x)
const _cphase = QuantumToolbox.tensor(_l00,_id) + QuantumToolbox.tensor(_l11,_z)
const _phase = _l00 + im*_l11
const _iphase = _l00 - im*_l11

const _f0₂ = QuantumToolbox.basis(2, 0)
const _f1₂ = QuantumToolbox.basis(2, 1)
const _ad₂ = QuantumToolbox.create(2)
const _a₂ = QuantumToolbox.destroy(2)
const _n₂ = QuantumToolbox.num(2)

express_nolookup(::HGate, ::QuantumToolboxRepr) = _hadamard
express_nolookup(::XGate, ::QuantumToolboxRepr) = _x
express_nolookup(::YGate, ::QuantumToolboxRepr) = _y
express_nolookup(::ZGate, ::QuantumToolboxRepr) = _z
express_nolookup(::CPHASEGate, ::QuantumToolboxRepr) = _cphase
express_nolookup(::CNOTGate, ::QuantumToolboxRepr) = _cnot

const xyzopdict = Dict(:X=>_x, :Y=>_y, :Z=>_z)
const xyzstatedict = Dict(:X=>(_s₊,_s₋),:Y=>(_i₊,_i₋),:Z=>(_l0,_l1))
for control in (:X, :Y, :Z)
    for target in (:X, :Y, :Z)
        k1, k2 = xyzstatedict[control]
        o = xyzopdict[target]
        gate = QuantumToolbox.tensor(proj(k1),_id) + QuantumToolbox.tensor(proj(k2),o)
        structname = Symbol(control,"C",target,"Gate")
        let gate=copy(gate)
            @eval express_nolookup(::$(structname), ::QuantumToolboxRepr) = $gate
        end
    end
end

express_nolookup(::PauliM, ::QuantumToolboxRepr) = _σ₋
express_nolookup(::PauliP, ::QuantumToolboxRepr) = _σ₊

express_nolookup(s::XBasisState, ::QuantumToolboxRepr) = (_s₊,_s₋)[s.idx]
express_nolookup(s::YBasisState, ::QuantumToolboxRepr) = (_i₊,_i₋)[s.idx]
express_nolookup(s::ZBasisState, ::QuantumToolboxRepr) = (_l0,_l1)[s.idx]

express_nolookup(s::FockState, r::QuantumToolboxRepr) = fock(r.cutoff, s.idx)
express_nolookup(s::CoherentState, r::QuantumToolboxRepr) = coherent(r.cutoff,s.alpha)
express_nolookup(s::SqueezedState, r::QuantumToolboxRepr) = (c = r.cutoff; squeeze(c, s.z)*fock(c, 0))
express_nolookup(o::NumberOp, r::QuantumToolboxRepr) = num(r.cutoff)
express_nolookup(o::CreateOp, r::QuantumToolboxRepr) = create(r.cutoff)
express_nolookup(o::DestroyOp, r::QuantumToolboxRepr) = destroy(r.cutoff)
express_nolookup(o::DisplaceOp, r::QuantumToolboxRepr) = displace(r.cutoff, o.alpha)
express_nolookup(o::SqueezeOp, r::QuantumToolboxRepr) = squeeze(r.cutoff, o.z)
express_nolookup(x::MixedState, r::QuantumToolboxRepr) = (l = length(x.basis); return qeye(l)/l)
express_nolookup(x::IdentityOp, r::QuantumToolboxRepr) = qeye(length(x.basis))

express_nolookup(s::SOuterKetBra, r::QuantumToolboxRepr) = proj(express(s.ket, r), express(s.bra, r))
express_nolookup(s::STensor, r::QuantumToolboxRepr) = QuantumToolbox.tensor((express(i, r) for i in s.terms)...)

end
