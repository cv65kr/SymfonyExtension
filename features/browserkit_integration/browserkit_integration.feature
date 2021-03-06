Feature: BrowserKit integration

    Background:
        Given a working Symfony application with SymfonyExtension configured
        And a Behat configuration containing:
        """
        default:
            suites:
                default:
                    contexts:
                        - App\Tests\SomeContext
        """
        And a feature file containing:
        """
        Feature:
            Scenario:
                When I visit the page "/hello-world"
                Then I should see "Hello world!" on the page

            # Doubling the scenario to account for some weird error
            Scenario:
                When I visit the page "/hello-world"
                Then I should see "Hello world!" on the page
        """

    Scenario: Injecting KernelBrowser manually
        Given a YAML services file containing:
            """
            services:
                App\Tests\SomeContext:
                    public: true
                    arguments:
                        - '@test.client'
            """
        And a context file "tests/SomeContext.php" containing:
        """
        <?php

        namespace App\Tests;

        use Behat\Behat\Context\Context;
        use FriendsOfBehat\SymfonyExtension\Mink\MinkParameters;
        use Psr\Container\ContainerInterface;
        use Symfony\Bundle\FrameworkBundle\KernelBrowser;

        final class SomeContext implements Context {
            /** @var KernelBrowser */
            private $client;

            public function __construct(KernelBrowser $client)
            {
                $this->client = $client;
            }

            /** @When I visit the page :page */
            public function visitPage(string $page): void
            {
                $this->client->request('GET', $page);
            }

            /** @Then I should see :content on the page */
            public function shouldSeeContentOnPage(string $content): void
            {
                assert(false !== strpos($this->client->getResponse()->getContent(), $content));
            }
        }
        """
        When I run Behat
        Then it should pass

    Scenario: Autowiring and autoconfiguring KernelBrowser client
        Given a YAML services file containing:
            """
            services:
                _defaults:
                    autowire: true
                    autoconfigure: true

                App\Tests\SomeContext: ~
            """
        And a context file "tests/SomeContext.php" containing:
        """
        <?php

        namespace App\Tests;

        use Behat\Behat\Context\Context;
        use FriendsOfBehat\SymfonyExtension\Mink\MinkParameters;
        use Psr\Container\ContainerInterface;
        use Symfony\Bundle\FrameworkBundle\KernelBrowser;

        final class SomeContext implements Context {
            /** @var KernelBrowser */
            private $client;

            public function __construct(KernelBrowser $client)
            {
                $this->client = $client;
            }

            /** @When I visit the page :page */
            public function visitPage(string $page): void
            {
                $this->client->request('GET', $page);
            }

            /** @Then I should see :content on the page */
            public function shouldSeeContentOnPage(string $content): void
            {
                assert(false !== strpos($this->client->getResponse()->getContent(), $content));
            }
        }
        """
        When I run Behat
        Then it should pass

    Scenario: Autowiring and autoconfiguring HttpKernelBrowser client
        Given a YAML services file containing:
            """
            services:
                _defaults:
                    autowire: true
                    autoconfigure: true

                App\Tests\SomeContext: ~
            """
        And a context file "tests/SomeContext.php" containing:
        """
        <?php

        namespace App\Tests;

        use Behat\Behat\Context\Context;
        use FriendsOfBehat\SymfonyExtension\Mink\MinkParameters;
        use Psr\Container\ContainerInterface;
        use Symfony\Component\HttpKernel\HttpKernelBrowser;

        final class SomeContext implements Context {
            /** @var HttpKernelBrowser */
            private $client;

            public function __construct(HttpKernelBrowser $client)
            {
                $this->client = $client;
            }

            /** @When I visit the page :page */
            public function visitPage(string $page): void
            {
                $this->client->request('GET', $page);
            }

            /** @Then I should see :content on the page */
            public function shouldSeeContentOnPage(string $content): void
            {
                assert(false !== strpos($this->client->getResponse()->getContent(), $content));
            }
        }
        """
        When I run Behat
        Then it should pass
