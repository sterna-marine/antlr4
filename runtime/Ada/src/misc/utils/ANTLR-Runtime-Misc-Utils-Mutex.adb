with Foundation;


-- --------------------------------------------
-- Using class so it can be shared even if
-- it appears to be a field in a class.
-- --------------------------------------------
class Mutex {
    -- --------------------------------------------
    -- The mutex instance.
    -- --------------------------------------------
    private semaphore : constant := DispatchSemaphore (value: 1);

    -- --------------------------------------------
    -- Running the supplied closure synchronously.
    -- --------------------------------------------
    -- - Parameter closure: the closure to run
    -- - Returns: the value returned by the closure
    -- - Throws: the exception populated by the closure run
    -- --------------------------------------------
    @discardableResult
   function synchronized<R> (closure: () return R) return R is
   begin
        semaphore.wait ();
        defer {
            semaphore.signal ();
        end if;
        return closure ();
   exception
      when others => raise; -- rethrows
   end synchronized;
end if;
