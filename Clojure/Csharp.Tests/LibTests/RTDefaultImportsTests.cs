/**
 *   Copyright (c) Rich Hickey. All rights reserved.
 *   The use and distribution terms for this software are covered by the
 *   Eclipse Public License 1.0 (http://opensource.org/licenses/eclipse-1.0.php)
 *   which can be found in the file epl-v10.html at the root of this distribution.
 *   By using this software in any fashion, you are agreeing to be bound by
 * 	 the terms of this license.
 *   You must not remove this notice, or any other, from this software.
 **/

using System;

using NUnit.Framework;
using static NExpect.Expectations;
using clojure.lang;
using NExpect;

// A deliberate collision with System.Tuple in the core library.  This assembly is
// loaded before RT's static initializer runs, so RT.CreateDefaultImportDictionary
// is guaranteed to see both types while it builds the default-import table.
namespace System
{
    public class Tuple { }
}

namespace Clojure.Tests.LibTests
{
    [TestFixture]
    public class RTDefaultImportsTests
    {
        [Test]
        public void DefaultImportsPrefersCoreLibraryOnNameCollision()
        {
            var t = (Type)RT.DefaultImports.valAt(Symbol.intern("Tuple"));

            Expect(t).To.Not.Be.Null();
            Expect(t.Assembly).To.Equal(typeof(object).Assembly);
        }

        [Test]
        public void DefaultImportsContainsBootstrapEntries()
        {
            Expect(RT.DefaultImports.valAt(Symbol.intern("StringBuilder"))).To.Equal(typeof(System.Text.StringBuilder));
            Expect(RT.DefaultImports.valAt(Symbol.intern("BigInteger"))).To.Equal(typeof(clojure.lang.BigInteger));
            Expect(RT.DefaultImports.valAt(Symbol.intern("BigDecimal"))).To.Equal(typeof(clojure.lang.BigDecimal));
        }
    }
}
