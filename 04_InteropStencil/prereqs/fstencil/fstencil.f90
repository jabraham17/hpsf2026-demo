subroutine myStencilInFortran(n, haloSize, in, out) bind(C, name="myStencilInFortran")
  use iso_c_binding
  integer(c_int), value :: n, haloSize
  real(c_double), intent(in)  :: in(n)
  real(c_double), intent(out) :: out(n)
  integer :: i

  do i = haloSize + 1, n - haloSize
    out(i) = (in(i - 1) + in(i) + in(i + 1)) / 3.0d0
  end do
end subroutine myStencilInFortran
