! Copyright (c) 2017 Matthew J. Smith and Overkit contributors
! License: MIT (http://opensource.org/licenses/MIT)

module ovkCart

  use ovkGlobal
  implicit none

  private

  ! API
  public :: ovk_cart
  public :: ovk_cart_
  public :: operator (==)
  public :: operator (/=)
  public :: ovkCartSize
  public :: ovkCartCount
  public :: ovkCartTupleToIndex
  public :: ovkCartIndexToTuple
  public :: ovkCartPeriodicAdjust
  public :: ovkCartContains
  public :: ovkCartClamp
  public :: ovkCartConvertPeriodicStorage
  public :: ovkCartConvertPointToCell

  type ovk_cart
    integer :: nd
    integer, dimension(MAX_ND) :: is, ie
    logical, dimension(MAX_ND) :: periodic
    integer :: periodic_storage
  end type ovk_cart

  ! Trailing _ added for compatibility with compilers that don't support F2003 constructors
  interface ovk_cart_
    module procedure ovk_cart_Default
    module procedure ovk_cart_AssignedNumPoints
    module procedure ovk_cart_AssignedNumPointsPeriodic
    module procedure ovk_cart_AssignedNumPointsPeriodicWithStorage
    module procedure ovk_cart_AssignedStartEnd
    module procedure ovk_cart_AssignedStartEndPeriodic
    module procedure ovk_cart_AssignedStartEndPeriodicWithStorage
  end interface ovk_cart_

  interface operator (==)
    module procedure ovk_cart_Equal
  end interface operator (==)

  interface operator (/=)
    module procedure ovk_cart_NotEqual
  end interface operator (/=)

contains

  pure function ovk_cart_Default(nDims) result(Cart)

    integer, intent(in) :: nDims
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is = 1
    Cart%ie(:nDims) = 0
    Cart%ie(nDims+1:) = 1
    Cart%periodic = .false.
    Cart%periodic_storage = OVK_NO_OVERLAP_PERIODIC

  end function ovk_cart_Default

  pure function ovk_cart_AssignedNumPoints(nDims, nPoints) result(Cart)

    integer, intent(in) :: nDims
    integer, dimension(nDims), intent(in) :: nPoints
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is = 1
    Cart%ie(:nDims) = nPoints
    Cart%ie(nDims+1:) = 1
    Cart%periodic = .false.
    Cart%periodic_storage = OVK_NO_OVERLAP_PERIODIC

  end function ovk_cart_AssignedNumPoints

  pure function ovk_cart_AssignedNumPointsPeriodic(nDims, nPoints, Periodic) result(Cart)

    integer, intent(in) :: nDims
    integer, dimension(nDims), intent(in) :: nPoints
    logical, dimension(nDims), intent(in) :: Periodic
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is = 1
    Cart%ie(:nDims) = nPoints
    Cart%ie(nDims+1:) = 1
    Cart%periodic(:nDims) = Periodic
    Cart%periodic(nDims+1:) = .false.
    Cart%periodic_storage = OVK_NO_OVERLAP_PERIODIC

  end function ovk_cart_AssignedNumPointsPeriodic

  pure function ovk_cart_AssignedNumPointsPeriodicWithStorage(nDims, nPoints, Periodic, &
    PeriodicStorage) result(Cart)

    integer, intent(in) :: nDims
    integer, dimension(nDims), intent(in) :: nPoints
    logical, dimension(nDims), intent(in) :: Periodic
    integer, intent(in) :: PeriodicStorage
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is = 1
    Cart%ie(:nDims) = nPoints
    Cart%ie(nDims+1:) = 1
    Cart%periodic(:nDims) = Periodic
    Cart%periodic(nDims+1:) = .false.
    Cart%periodic_storage = PeriodicStorage

  end function ovk_cart_AssignedNumPointsPeriodicWithStorage

  pure function ovk_cart_AssignedStartEnd(nDims, iStart, iEnd) result(Cart)

    integer, intent(in) :: nDims
    integer, dimension(nDims), intent(in) :: iStart, iEnd
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is(:nDims) = iStart
    Cart%is(nDims+1:) = 1
    Cart%ie(:nDims) = iEnd
    Cart%ie(nDims+1:) = 1
    Cart%periodic = .false.
    Cart%periodic_storage = OVK_NO_OVERLAP_PERIODIC

  end function ovk_cart_AssignedStartEnd

  pure function ovk_cart_AssignedStartEndPeriodic(nDims, iStart, iEnd, Periodic) result(Cart)

    integer, intent(in) :: nDims
    integer, dimension(nDims), intent(in) :: iStart, iEnd
    logical, dimension(nDims), intent(in) :: Periodic
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is(:nDims) = iStart
    Cart%is(nDims+1:) = 1
    Cart%ie(:nDims) = iEnd
    Cart%ie(nDims+1:) = 1
    Cart%periodic(:nDims) = Periodic
    Cart%periodic(nDims+1:) = .false.
    Cart%periodic_storage = OVK_NO_OVERLAP_PERIODIC

  end function ovk_cart_AssignedStartEndPeriodic

  pure function ovk_cart_AssignedStartEndPeriodicWithStorage(nDims, iStart, iEnd, Periodic, &
    PeriodicStorage) result(Cart)

    integer, intent(in) :: nDims
    integer, dimension(nDims), intent(in) :: iStart, iEnd
    logical, dimension(nDims), intent(in) :: Periodic
    integer, intent(in) :: PeriodicStorage
    type(ovk_cart) :: Cart

    Cart%nd = nDims
    Cart%is(:nDims) = iStart
    Cart%is(nDims+1:) = 1
    Cart%ie(:nDims) = iEnd
    Cart%ie(nDims+1:) = 1
    Cart%periodic(:nDims) = Periodic
    Cart%periodic(nDims+1:) = .false.
    Cart%periodic_storage = PeriodicStorage

  end function ovk_cart_AssignedStartEndPeriodicWithStorage

  pure function ovk_cart_Equal(LeftCart, RightCart) result(Equal)

    type(ovk_cart), intent(in) :: LeftCart, RightCart
    logical :: Equal

    Equal = &
      LeftCart%nd == RightCart%nd .and. &
      all(LeftCart%is == RightCart%is) .and. &
      all(LeftCart%ie == RightCart%ie) .and. &
      all(LeftCart%periodic .eqv. RightCart%periodic) .and. &
      LeftCart%periodic_storage == RightCart%periodic_storage

  end function ovk_cart_Equal

  pure function ovk_cart_NotEqual(LeftCart, RightCart) result(NotEqual)

    type(ovk_cart), intent(in) :: LeftCart, RightCart
    logical :: NotEqual

    NotEqual = .not. ovk_cart_Equal(LeftCart, RightCart)

  end function ovk_cart_NotEqual

  pure function ovkCartSize(Cart) result(nPoints)

    type(ovk_cart), intent(in) :: Cart
    integer, dimension(Cart%nd) :: nPoints

    nPoints = Cart%ie(:Cart%nd) - Cart%is(:Cart%nd) + 1

  end function ovkCartSize

  pure function ovkCartCount(Cart) result(nPointsTotal)

    type(ovk_cart), intent(in) :: Cart
    integer(lk) :: nPointsTotal

    integer(lk), dimension(Cart%nd) :: nPoints

    nPoints = int(Cart%ie(:Cart%nd)-Cart%is(:Cart%nd)+1, kind=lk)

    nPointsTotal = product(nPoints)

  end function ovkCartCount

  pure function ovkCartTupleToIndex(Cart, Tuple) result(Ind)

    type(ovk_cart), intent(in) :: Cart
    integer, dimension(Cart%nd), intent(in) :: Tuple
    integer(lk) :: Ind

    integer :: i
    integer(lk), dimension(Cart%nd) :: N
    integer(lk), dimension(Cart%nd) :: Stride

    N = Cart%ie(:Cart%nd) - Cart%is(:Cart%nd) + 1
    Stride = [(product(N(:i)),i=0,Cart%nd-1)]

    Ind = 1 + sum(Stride * (Tuple - Cart%is(:Cart%nd)))

  end function ovkCartTupleToIndex

  pure function ovkCartIndexToTuple(Cart, Ind) result(Tuple)

    type(ovk_cart), intent(in) :: Cart
    integer(lk), intent(in) :: Ind
    integer, dimension(Cart%nd) :: Tuple

    integer :: i
    integer(lk), dimension(Cart%nd) :: N
    integer(lk), dimension(Cart%nd) :: Stride

    N = Cart%ie(:Cart%nd) - Cart%is(:Cart%nd) + 1
    Stride = [(product(N(:i)),i=0,Cart%nd-1)]

    Tuple = Cart%is(:Cart%nd) + int(modulo((Ind-1)/Stride, N))

  end function ovkCartIndexToTuple

  pure function ovkCartPeriodicAdjust(Cart, Point) result(AdjustedPoint)

    type(ovk_cart), intent(in) :: Cart
    integer, dimension(Cart%nd), intent(in) :: Point
    integer, dimension(Cart%nd) :: AdjustedPoint

    integer, dimension(Cart%nd) :: nPeriod

    nPeriod = Cart%ie(:Cart%nd) - Cart%is(:Cart%nd) + 1
    nPeriod = merge(nPeriod-1, nPeriod, Cart%periodic(:Cart%nd) .and. &
        Cart%periodic_storage == OVK_OVERLAP_PERIODIC)

    AdjustedPoint = merge(modulo(Point-1, nPeriod)+1, Point, Cart%periodic(:Cart%nd))

  end function ovkCartPeriodicAdjust

  pure function ovkCartContains(Cart, Point) result(CartContains)

    type(ovk_cart), intent(in) :: Cart
    integer, dimension(Cart%nd), intent(in) :: Point
    logical :: CartContains

    CartContains = all(Point >= Cart%is(:Cart%nd)) .and. all(Point <= Cart%ie(:Cart%nd))

  end function ovkCartContains

  pure function ovkCartClamp(Cart, Point) result(ClampedPoint)

    type(ovk_cart), intent(in) :: Cart
    integer, dimension(Cart%nd), intent(in) :: Point
    integer, dimension(Cart%nd) :: ClampedPoint

    ClampedPoint = min(max(Point, Cart%is(:Cart%nd)), Cart%ie(:Cart%nd))

  end function ovkCartClamp

  pure function ovkCartConvertPeriodicStorage(Cart, PeriodicStorage) result(ConvertedCart)

    type(ovk_cart), intent(in) :: Cart
    integer, intent(in) :: PeriodicStorage
    type(ovk_cart) :: ConvertedCart

    ConvertedCart = Cart
    ConvertedCart%periodic_storage = PeriodicStorage

    if (ConvertedCart%periodic_storage /= Cart%periodic_storage) then
      if (Cart%periodic_storage == OVK_OVERLAP_PERIODIC) then
        ConvertedCart%ie = merge(ConvertedCart%ie-1, ConvertedCart%ie, ConvertedCart%periodic)
      else
        ConvertedCart%ie = merge(ConvertedCart%ie+1, ConvertedCart%ie, ConvertedCart%periodic)
      end if
    end if

  end function ovkCartConvertPeriodicStorage

  pure function ovkCartConvertPointToCell(Cart) result(CellCart)

    type(ovk_cart), intent(in) :: Cart
    type(ovk_cart) :: CellCart

    CellCart = Cart

    if (Cart%periodic_storage == OVK_NO_OVERLAP_PERIODIC) then
      CellCart%ie(:Cart%nd) = merge(Cart%ie(:Cart%nd), Cart%ie(:Cart%nd)-1, Cart%periodic(:Cart%nd))
    else
      CellCart%ie(:Cart%nd) = Cart%ie(:Cart%nd)-1
    end if

    CellCart%periodic_storage = OVK_NO_OVERLAP_PERIODIC

  end function ovkCartConvertPointToCell

end module ovkCart
