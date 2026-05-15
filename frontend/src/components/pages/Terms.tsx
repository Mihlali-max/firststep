import { Link } from 'react-router-dom'
export default function Terms() {
  return (
    <div className="min-h-screen bg-[#FFFDF7]">
      <div className="bg-[#1A1A0F] py-14 px-6">
        <div className="max-w-3xl mx-auto">
          <p className="text-[#F5A623] text-xs font-semibold tracking-[3px] uppercase mb-3">Legal</p>
          <h1 className="font-display text-4xl font-bold text-[#FFFDF7]">Terms of Use</h1>
          <p className="text-[#FFFDF7]/40 text-sm mt-2">Last updated: 15 May 2026</p>
        </div>
      </div>
      <div className="max-w-3xl mx-auto px-6 py-14 space-y-10 text-black/65 text-sm leading-relaxed">

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">1. Acceptance</h2>
          <p>By using FirstStep you agree to these terms. If you do not agree, please do not use the platform. These terms are governed by South African law.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">2. The service</h2>
          <p className="mb-3">FirstStep provides:</p>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>A free CV builder with PDF download</li>
            <li>Live SA job and learnership listings aggregated from third-party sources</li>
            <li>An AI-powered career coaching chatbot</li>
            <li>Information about government employment programmes</li>
            <li>Email job alerts (opt-in only)</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">3. Job listings disclaimer</h2>
          <p className="mb-3">Job listings on FirstStep are sourced from Adzuna and other third parties. We do not verify every listing. <strong className="text-black/80">Always verify opportunities directly with the employer before paying any money or sharing sensitive personal information.</strong></p>
          <p>FirstStep will never ask you to pay to apply for a job or learnership. If someone claiming to be from FirstStep asks you for money, it is a scam.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">4. AI Coach</h2>
          <p>The AI Coach is powered by a large language model and provides general career guidance. It is not a qualified career counsellor, legal advisor, or recruitment professional. Do not rely solely on AI Coach advice for important career decisions.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">5. Your account</h2>
          <ul className="list-disc pl-5 space-y-1.5">
            <li>You must be 13 or older to use FirstStep</li>
            <li>You are responsible for keeping your password secure</li>
            <li>You may not create accounts for other people without their permission</li>
            <li>You may not use FirstStep for any unlawful purpose</li>
          </ul>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">6. Your content</h2>
          <p>The CV information you enter remains yours. By using FirstStep you give us permission to store and process it to provide the service (generating your PDF, sending alerts, etc.). We do not claim ownership of your CV content.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">7. Limitation of liability</h2>
          <p>FirstStep is provided free of charge and "as is". We are not liable for any losses arising from your use of the platform, including missed job opportunities, incorrect information in listings, or AI Coach advice.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">8. Termination</h2>
          <p>We may suspend or terminate accounts that violate these terms. You may delete your account at any time by contacting us.</p>
        </section>

        <section>
          <h2 className="font-display text-xl font-bold text-[#1A1A0F] mb-3">9. Contact</h2>
          <p>For any questions about these terms email <a href="mailto:momozamihlali@gmail.com" className="text-[#C47D0A] underline">momozamihlali@gmail.com</a> or use the <Link to="/contact" className="text-[#C47D0A] underline">contact form</Link>.</p>
        </section>

      </div>
    </div>
  )
}
