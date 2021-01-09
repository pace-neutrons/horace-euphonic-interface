function out = mp_grid(sz)
% Returns a Monkhorst-Pack grid of specified size
    euphonic_on();
    out = py.euphonic.util.mp_grid(int32(sz));
end
