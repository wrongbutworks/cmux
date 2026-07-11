import Testing
import CmuxTerminal

@Suite
struct TerminalSurfaceResizePolicyTests {
    @Test
    func sameGridPixelChangeIsCoalesced() {
        #expect(
            !TerminalSurface.shouldApplySurfacePixelSizeChange(
                currentColumns: 80,
                currentRows: 24,
                targetColumns: 80,
                targetRows: 24,
                coalescePixelOnlyResize: true,
                hasAppliedPixelSize: true
            )
        )
    }

    @Test
    func gridChangesApply() {
        #expect(
            TerminalSurface.shouldApplySurfacePixelSizeChange(
                currentColumns: 80,
                currentRows: 24,
                targetColumns: 79,
                targetRows: 24,
                coalescePixelOnlyResize: true,
                hasAppliedPixelSize: true
            )
        )
        #expect(
            TerminalSurface.shouldApplySurfacePixelSizeChange(
                currentColumns: 80,
                currentRows: 24,
                targetColumns: 80,
                targetRows: 25,
                coalescePixelOnlyResize: true,
                hasAppliedPixelSize: true
            )
        )
    }

    @Test
    func coalescingBypassesOrdinaryLayoutAndFirstApply() {
        #expect(
            TerminalSurface.shouldApplySurfacePixelSizeChange(
                currentColumns: 80,
                currentRows: 24,
                targetColumns: 80,
                targetRows: 24,
                coalescePixelOnlyResize: false,
                hasAppliedPixelSize: true
            )
        )
        #expect(
            TerminalSurface.shouldApplySurfacePixelSizeChange(
                currentColumns: 80,
                currentRows: 24,
                targetColumns: 80,
                targetRows: 24,
                coalescePixelOnlyResize: true,
                hasAppliedPixelSize: false
            )
        )
    }

    @Test
    func invalidGridPredictionFailsOpen() {
        #expect(
            TerminalSurface.shouldApplySurfacePixelSizeChange(
                currentColumns: 80,
                currentRows: 24,
                targetColumns: 0,
                targetRows: 0,
                coalescePixelOnlyResize: true,
                hasAppliedPixelSize: true
            )
        )
    }
}
