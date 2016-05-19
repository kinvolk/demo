package potato_test

import (
	"time"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"
	"github.com/sclevine/agouti"
	. "github.com/sclevine/agouti/matchers"
)

var _ = Describe("UserLogin", func() {
	var page *agouti.Page
	salutations := "Good morning at " + time.Now().String()

	BeforeEach(func() {
		var err error
		page, err = agoutiDriver.NewPage(agouti.Browser("firefox"))
		Expect(err).NotTo(HaveOccurred())
		page.SetImplicitWait(10000)
	})

	AfterEach(func() {
		Expect(page.Destroy()).To(Succeed())
	})

	It("should be able to add an entry", func() {
		By("redirecting the user to the page", func() {
			Expect(page.Navigate("http://localhost:8083/")).To(Succeed())
			Expect(page).To(HaveURL("http://localhost:8083/"))
		})

		By("loading the page completely", func() {
			Eventually(page.Find(".form-control"), "10s").Should(BeFound())
			Eventually(page.Find("#redis-resp"), "10s").ShouldNot(HaveText("Loading..."))
		})

		By("allowing the user to fill out the login form and submit it", func() {
			Expect(page.Find(".form-control").Fill(salutations)).To(Succeed())
			Expect(page.Find(".btn-primary").Click()).To(Succeed())
			Eventually(page.Find("#redis-resp")).Should(HaveText("Sending..."))
		})

		By("allowing the user to see the text", func() {
			Eventually(page.Find(".class-messages:last-of-type"), "10s").Should(HaveText(salutations))
		})

	})
})
