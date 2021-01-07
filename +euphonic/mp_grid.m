function out = mp_grid(sz)
% Returns a Monkhorst-Pack grid of specified size
    out = py.euphonic_wrapper.mp_grid(int32(sz));
end
