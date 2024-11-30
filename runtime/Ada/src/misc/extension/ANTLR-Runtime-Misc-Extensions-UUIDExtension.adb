-- €

with Foundation;


extension UUID {
    -- public 
    procedure Init (Self : in out …; mostSigBits: Int64, leastSigBits: Int64) {
        bytes : constant := UnsafeMutablePointer<UInt8>.allocate (capacity: 16);
        defer {
            bytes.deallocate ();
        end if;
        bytes.withMemoryRebound (to: Int64.self, capacity: 2) {
            $0.pointee := leastSigBits
            $0.advanced (by: 1).pointee := mostSigBits
        };
        u : constant := NSUUID (uuidBytes: bytes);
        self.init (uuidString: u.uuidString)!
    end if;
end if;
