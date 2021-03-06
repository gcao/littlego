// -----------------------------------------------------------------------------
// Copyright 2011-2012 Patrick Näf (herzbube@herzbube.ch)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------


// Forward declarations
@class GoPoint;


// -----------------------------------------------------------------------------
/// @brief The PlayView class is a custom view that is responsible for drawing
/// a Go board.
///
/// The view content is drawn in layers:
/// - View background
/// - Board background
/// - Grid lines
/// - Cross-hair lines (during stone placement)
/// - Star points
/// - Played stones (if any)
/// - Cross-hair stone (during stone placement)
/// - Symbols (if any)
/// - Coordinate labels (if any)
/// - Territory coloring (in scoring mode only)
/// - Dead stone state (in scoring mode only)
///
/// In addition, PlayView writes text into a status line and animates an
/// activity indicator, to provide the user with feedback about operations
/// that are currently going on.
///
///
/// @par Delayed updates
///
/// If a long-running action is started (the typical example is loading a game)
/// which would cause many view updates, a client can prevent those updates
/// from taking place immediately by invoking actionStarts(). Events that would
/// normally trigger drawing updates are processed as normal, but the drawing
/// itself is delayed. When actionEnds() is invoked, all drawing updates that
/// have accumulated are now coalesced into a single update.
///
/// actionStarts() may be invoked multiple times, but each invocation must be
/// paired with a matching call to actionEnds(). The drawing update occurs only
/// when the last matching call to actionEnds() occurs.
///
/// @note Clients that want to update the view directly should invoke
/// delayedUpdate() instead of setNeedsDisplay(). Using delayedUpdate() makes
/// sure that the update occurs at the right time, either immediately, or after
/// a long-running action has ended.
///
///
/// @par Implementation notes
///
/// PlayView acts as a facade that hides the drawing and layer management
/// details from outside forces. For instance, although PlayViewController
/// closely interacts with PlayView, it does not need to know how exactly the
/// Go board is drawn. One early implementation of PlayView did all the drawing
/// in a single drawRect:() implementation, while later implementations
/// distributed responsibility for drawing each layer to dedicated layer
/// delegate classes. Because this happened behind the PlayView facade, there
/// was no need to change PlayViewController.
///
/// If we look at PlayView from the inside of the facade, its main
/// responsibility is that of a coordinating agent. PlayView is the central
/// receiver of events that occur in the application. It distributes those
/// events to all of its sub-objects, which then decide on their own whether
/// they are affected by each event, and how. If necessary, PlayView updates
/// drawing metrics before an event is distributed. After an event is
/// distributed, PlayView initiates redrawing at the proper moment. This may
/// be immediately, or after some delay. See the "Delayed updates" section
/// above.
// -----------------------------------------------------------------------------
@interface PlayView : UIView
{
}

+ (PlayView*) sharedView;
- (GoPoint*) crossHairPointNear:(CGPoint)coordinates;
- (void) moveCrossHairTo:(GoPoint*)point isLegalMove:(bool)isLegalMove;
- (GoPoint*) pointNear:(CGPoint)coordinates;
- (void) actionStarts;
- (void) actionEnds;
- (void) frameChanged;

/// @name Cross-hair point properties
//@{
/// @brief Refers to the GoPoint object that marks the focus of the cross-hair.
///
/// Observers may monitor this property via KVO. If this property changes its
/// value, observers can also get a correctly updated value from property
/// @e crossHairPointIsLegalMove.
@property(nonatomic, retain) GoPoint* crossHairPoint;
/// @brief Is true if the GoPoint object at the focus of the cross-hair
/// represents a legal move.
///
/// This property cannot be monitored via KVO.
@property(nonatomic, assign) bool crossHairPointIsLegalMove;
//@}

@end
