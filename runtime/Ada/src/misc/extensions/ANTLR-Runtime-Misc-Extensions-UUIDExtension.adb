-- €

with Foundation;


extension UUID {
    -- public
    procedure Initialize (Self : in out …; mostSigBits: Integer_64, leastSigBits => Integer_64) {
        bytes : constant := UnsafeMutablePointer<Unsigned_8>.allocate (capacity => 16);
        defer {
            bytes.deallocate ();
        end if;
        bytes.withMemoryRebound (to => Integer_64.self, capacity => 2) {
            $0.pointee := leastSigBits
            $0.advanced (by => 1).pointee := mostSigBits
        };
        u : constant := NSUUID (uuidBytes => bytes);
        Self.Initialize (uuidString => u.uuidString)!
    end if;
end if;
